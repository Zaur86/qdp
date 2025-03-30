import sys
import yaml
from kafka.admin import KafkaAdminClient, NewTopic
from app import get_settings

if len(sys.argv) != 3:
    print("Usage: python etl/init/create_topics.py <enviroment> <yaml_file_path>")
    sys.exit(1)

env = sys.argv[1].upper()
topics_file = sys.argv[2]
settings = get_settings(env)

with open(topics_file, "r") as f:
    config = yaml.safe_load(f)

topics_config = config.get("topics", [])

admin_client = KafkaAdminClient(
    bootstrap_servers=settings.KAFKA_BOOTSTRAP_SERVERS,
    security_protocol=settings.KAFKA_SECURITY_PROTOCOL,
    client_id=f"create_topics_{env.lower()}"
)

new_topics = [
    NewTopic(name=topic["name"],
             num_partitions=topic.get("partitions", 1),
             replication_factor=topic.get("replication", 1))
    for topic in topics_config
]

try:
    admin_client.create_topics(new_topics=new_topics, validate_only=False)
    print(f"✅ Topics created from {topics_file}:")
    for t in new_topics:
        print(f"  - {t.name}")
except Exception as e:
    print("⚠️ Error creating topics:", e)
