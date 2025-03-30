import sys
import yaml
from kafka.admin import KafkaAdminClient
from app import get_settings

if len(sys.argv) != 3:
    print("Usage: python utils/kafka/delete_topics.py <environment> <yaml_file_path>")
    sys.exit(1)

env = sys.argv[1].upper()
topics_file = sys.argv[2]
settings = get_settings(env)

with open(topics_file, "r") as f:
    config = yaml.safe_load(f)

topics = [t["name"] for t in config.get("topics", [])]

print(f"⚠️  You're about to delete {len(topics)} topic(s) in environment: {env}")
for t in topics:
    print(f"  - {t}")

confirm = input("❗ Type 'yes' to confirm deletion: ").strip().lower()

if confirm != "yes":
    print("❌ Aborted.")
    sys.exit(0)

admin_client = KafkaAdminClient(
    bootstrap_servers=settings.KAFKA_BOOTSTRAP_SERVERS,
    security_protocol=settings.KAFKA_SECURITY_PROTOCOL,
    client_id=f"delete_topics_{env.lower()}"
)

try:
    admin_client.delete_topics(topics)
    print(f"🗑️  Deleted topics:")
    for t in topics:
        print(f"  - {t}")
except Exception as e:
    print(f"⚠️ Error deleting topics: {e}")
