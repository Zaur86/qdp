import sys
import time
import requests
import urllib3
from dataclasses import dataclass
from app import get_settings

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

@dataclass
class NifiFlowBuilder:
    flow_name: str
    flow_type: str  # "LOG", "S3", and e.t.c
    flow_params: dict
    env: str
    verify_ssl: bool = False
    retry_attempts: int = 10
    retry_delay: float = 1
    position_start: tuple = (100.0, 100.0)
    position_step: tuple = (200.0, 100.0)
    backpressure_data_size: str = "1 GB"
    backpressure_object_threshold: str = "10000"

    def __post_init__(self):
        self.settings = get_settings(self.env)

        self.NIFI_API = self.settings.NIFI_HOST
        self.AUTH = (self.settings.NIFI_USERNAME, self.settings.NIFI_PASSWORD)
        self.VERIFY_SSL = self.verify_ssl
        self.headers = {"Content-Type": "application/json"}
        self.used_positions = set()

        # Kafka
        self.KAFKA_BROKER = self.settings.KAFKA_BOOTSTRAP_SERVERS

        # MinIO / S3
        self.MINIO_ENDPOINT = self.settings.MINIO_SERVER
        self.MINIO_BUCKET = self.settings.MINIO_BUCKET
        self.MINIO_ACCESS_KEY = self.settings.MINIO_ROOT_USER
        self.MINIO_SECRET_KEY = self.settings.MINIO_ROOT_PASSWORD

        # flow-specific
        self.flow_type = self.flow_type.upper()
        self.flow_name = self.flow_name
        self.flow_params = self.flow_params

    def authenticate(self):
        url = f"{self.NIFI_API}/access/token"
        data = {
            "username": self.settings.NIFI_USERNAME,
            "password": self.settings.NIFI_PASSWORD
        }
        print(f"🔐 Requesting access token from {url}...")
        r = requests.post(url, data=data, verify=self.VERIFY_SSL)
        if r.status_code not in (200, 201):
            print(f"❌ Failed to get token: {r.status_code} - {r.text}")
            sys.exit(1)
        token = r.text
        self.headers["Authorization"] = f"Bearer {token}"
        print("✅ Authenticated with NiFi API.")

    def get_root_pg_id(self):
        url = f"{self.NIFI_API}/flow/process-groups/root"
        print(f"📡 GET {url}")
        r = requests.get(url, headers=self.headers, verify=self.VERIFY_SSL)
        r.raise_for_status()
        return r.json()["processGroupFlow"]["id"]

    def find_available_position(self):
        x, y = self.position_start
        dx, dy = self.position_step
        while (x, y) in self.used_positions:
            x += dx
            if x > 2000:
                x = self.position_start[0]
                y += dy
        self.used_positions.add((x, y))
        return x, y

    def create_process_group(self, parent_id, name):
        position = self.find_available_position()
        payload = {
            "component": {"name": name, "position": {"x": position[0], "y": position[1]}},
            "revision": {"version": 0}
        }
        r = requests.post(f"{self.NIFI_API}/process-groups/{parent_id}/process-groups",
                          headers=self.headers, json=payload, verify=self.VERIFY_SSL)
        return r.json()["id"]

    def create_processor(self, pg_id, processor_cfg):
        position = self.find_available_position()
        component = {
            "type": processor_cfg["type"],
            "name": processor_cfg["name"],
            "position": {"x": position[0], "y": position[1]}
        }
        if processor_cfg.get("bundle"):
            component["bundle"] = processor_cfg["bundle"]

        payload = {
            "component": component,
            "revision": {"version": 0}
        }

        last_response = None
        for attempt in range(self.retry_attempts):
            r = requests.post(f"{self.NIFI_API}/process-groups/{pg_id}/processors",
                              headers=self.headers, json=payload, verify=self.VERIFY_SSL)
            if r.status_code in (200, 201):
                return r.json()["component"]
            last_response = r
            print(f"❌ Attempt {attempt + 1}: Failed to create processor: {r.status_code} {r.text}")
            time.sleep(self.retry_delay)

        if last_response:
            last_response.raise_for_status()

    def create_controller_service(self, pg_id, type_, name, bundle, properties=None):
        url = f"{self.NIFI_API}/process-groups/{pg_id}/controller-services"
        component = {
            "type": type_,
            "name": name,
            "properties": properties or {},
            "bundle": bundle
        }

        payload = {
            "component": component,
            "revision": {"version": 0}
        }
        r = requests.post(url, headers=self.headers, json=payload, verify=self.VERIFY_SSL)
        r.raise_for_status()
        return r.json()["id"]

    def enable_controller_service(self, service_id):
        # Step 1: Get current revision
        url = f"{self.NIFI_API}/controller-services/{service_id}"
        r = requests.get(url, headers=self.headers, verify=self.VERIFY_SSL)
        r.raise_for_status()
        current = r.json()

        # Step 2: Update state to ENABLED
        payload = {
            "revision": current["revision"],
            "component": {
                "id": service_id,
                "state": "ENABLED"
            }
        }
        print(f"⚙️ Enabling controller service: {service_id}")
        r = requests.put(url, headers=self.headers, json=payload, verify=self.VERIFY_SSL)
        r.raise_for_status()

        # Step 3: Wait until it becomes enabled (optional, но лучше добавить)
        for _ in range(self.retry_attempts):
            r = requests.get(url, headers=self.headers, verify=self.VERIFY_SSL)
            state = r.json()["component"]["state"]
            if state == "ENABLED":
                print(f"✅ Controller service enabled: {service_id}")
                return
            time.sleep(self.retry_delay)
        print(f"⚠️ Controller service {service_id} still not enabled after waiting.")

    def update_processor_config(self, processor_id, properties):
        url = f"{self.NIFI_API}/processors/{processor_id}"

        last_response = None
        for attempt in range(self.retry_attempts):
            try:
                r = requests.get(url, headers=self.headers, verify=self.VERIFY_SSL)
                r.raise_for_status()
                current = r.json()
                revision = current["revision"]

                payload = {
                    "revision": revision,
                    "component": {
                        "id": processor_id,
                        "config": {
                            "properties": properties
                        }
                    }
                }

                r = requests.put(url, headers=self.headers, json=payload, verify=self.VERIFY_SSL)
                if r.status_code in (200, 201):
                    return
                else:
                    last_response = r
                    print(f"❌ PUT attempt {attempt + 1} failed: {r.status_code} {r.text}")
            except requests.exceptions.RequestException as e:
                print(f"❌ Attempt {attempt + 1} failed with error: {e}")

            time.sleep(self.retry_delay)

        if last_response:
            last_response.raise_for_status()

    def get_relationships(self, processor_id):
        url = f"{self.NIFI_API}/processors/{processor_id}"
        r = requests.get(url, headers=self.headers, verify=self.VERIFY_SSL)
        r.raise_for_status()
        return [rel["name"] for rel in r.json()["component"].get("relationships", [])]

    def create_connection(self, pg_id, source_id, dest_id):
        relationships = self.get_relationships(source_id)

        url = f"{self.NIFI_API}/process-groups/{pg_id}/connections"
        payload = {
            "revision": {"version": 0},
            "component": {
                "source": {"id": source_id, "type": "PROCESSOR", "groupId": pg_id},
                "destination": {"id": dest_id, "type": "PROCESSOR", "groupId": pg_id},
                "selectedRelationships": relationships,
                "backPressureDataSizeThreshold": self.backpressure_data_size,
                "backPressureObjectThreshold": self.backpressure_object_threshold
            }
        }
        r = requests.post(url, headers=self.headers, json=payload, verify=self.VERIFY_SSL)
        r.raise_for_status()

    def wait_until_controller_service_ready(self, service_id):
        """Wait until the controller service is fully available and usable in processor configs."""
        url = f"{self.NIFI_API}/controller-services/{service_id}"
        for attempt in range(self.retry_attempts):
            r = requests.get(url, headers=self.headers, verify=self.VERIFY_SSL)
            if r.status_code == 200:
                state = r.json()["component"]["state"]
                if state in ("ENABLED", "ENABLING", "DISABLED"):
                    print(f"🟢 Controller service {service_id} is {state} (attempt {attempt + 1})")
                    return
            print(f"⏳ Waiting for controller service {service_id} to become available... (attempt {attempt + 1})")
            time.sleep(self.retry_delay)
        raise RuntimeError(f"Controller service {service_id} is not ready after retries.")

    def wait_until_valid(self, component_id, component_type="processors"):
        url = f"{self.NIFI_API}/{component_type}/{component_id}"
        for _ in range(self.retry_attempts):
            r = requests.get(url, headers=self.headers, verify=self.VERIFY_SSL)
            r.raise_for_status()
            if r.json()["component"]["validationStatus"] == "VALID":
                return
            time.sleep(self.retry_delay)
        raise RuntimeError(f"{component_type[:-1].capitalize()} {component_id} is not valid after retries.")

    def auto_terminate_relationships(self, processor_id, relationships):
        url = f"{self.NIFI_API}/processors/{processor_id}"
        r = requests.get(url, headers=self.headers, verify=self.VERIFY_SSL)
        r.raise_for_status()
        current = r.json()
        revision = current["revision"]

        payload = {
            "revision": revision,
            "component": {
                "id": processor_id,
                "config": {
                    "autoTerminatedRelationships": relationships
                }
            }
        }

        print(f"🛑 Auto-terminating relationships for {processor_id}: {relationships}")
        r = requests.put(url, headers=self.headers, json=payload, verify=self.VERIFY_SSL)
        r.raise_for_status()

    def run(self):
        """Authenticate and run the flow based on the selected type."""
        self.authenticate()
        root_pg = self.get_root_pg_id()
        pg_id = self.create_process_group(root_pg, self.flow_name)
        print(f"✅ Created process group: {self.flow_name} (ID: {pg_id})")

        if self.flow_type == "LOG":
            self.create_logs_flow(pg_id)
        #elif self.flow_type == "S3":
            #self.create_s3_flow(pg_id)
        else:
            raise ValueError(f"Unknown flow type: {self.flow_type}")

        print("✅ Flow initialized and processors created.")

    def create_logs_flow(self, pg_id):
        """Builds a Kafka → Log flow using controller services first (correct order)."""

        params = self.flow_params
        processors = params["processors"]
        controllers = params.get("controller_services", {})

        topic = params["kafka_topic"]
        batch_size = params.get("kafka_batch_size", 100)
        offset_reset = params.get("kafka_auto_offset_reset", "earliest")
        enable_commit = str(params.get("kafka_enable_auto_commit", False)).lower()

        # Step 1: Create controller services first
        controller_ids = {}
        for key, cfg in controllers.items():
            controller_ids[key] = self.create_controller_service(
                pg_id, cfg["type"], cfg["name"], cfg["bundle"], cfg.get("properties")
            )

        print("💡 READER ID:", controller_ids["json_reader"])
        print("💡 WRITER ID:", controller_ids["json_writer"])

        # Step 2: Wait and enable all controller services
        for service_id in controller_ids.values():
            self.wait_until_controller_service_ready(service_id)
            self.enable_controller_service(service_id)

        # Step 3: Create processors after controllers are ready
        kafka_proc = self.create_processor(pg_id, processors["kafka"])
        print(f"✅ Kafka processor created: {kafka_proc['id']}")
        log_proc = self.create_processor(pg_id, processors["logger"])
        print(f"✅ Logs processor created: {log_proc['id']}")
        file_proc = self.create_processor(pg_id, processors["putfile"])
        print(f"✅ File processor created: {file_proc['id']}")

        # 👉 Step 3.5: Auto-terminate unused relationships
        #self.auto_terminate_relationships(kafka_proc["id"], ["success", "parse.failure"])
        #self.auto_terminate_relationships(log_proc["id"], ["success"])

        # Step 4: Configure proxessors
        self.update_processor_config(kafka_proc["id"], {
            "bootstrap.servers": self.KAFKA_BROKER,
            "topic": topic,
            "group.id": f"{self.flow_name.replace(' ', '_')}_group",
            "auto.offset.reset": offset_reset,
            "enable.auto.commit": enable_commit,
            "record-reader": controller_ids.get("json_reader"),
            "record-writer": controller_ids.get("json_writer"),
            "max.poll.records": str(batch_size),
        })
        self.update_processor_config(file_proc["id"], params["putfile_properties"])

        # Step 5: Create connections
        self.create_connection(pg_id, kafka_proc["id"], log_proc["id"])
        self.create_connection(pg_id, log_proc["id"], file_proc["id"])
        print("✅ Kafka → Log -> File connections created")

        # Step 5.5: Auto terminate Log Processor
        self.auto_terminate_relationships(file_proc["id"], ["success", "failure"])
        print("✅ File Processor auto terminated")

        # Step 6: Check processors are valid
        self.wait_until_valid(kafka_proc["id"])
        print("✅ Kafka processor is valid")

        self.wait_until_valid(log_proc["id"])
        print("✅ Logs processor is valid")

        self.wait_until_valid(file_proc["id"])
        print("✅ File processor is valid")

        print("🟢 Kafka → Log -> File flow is ready")
