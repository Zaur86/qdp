from dataclasses import dataclass
from dotenv import load_dotenv
import os

# Load .env file
load_dotenv()


# All modes
@dataclass()
class BaseSettings:
    POSTGRES_USER = os.getenv("POSTGRES_USER")
    POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD")
    POSTGRES_DB = os.getenv("POSTGRES_DB")
    POSTGRES_HOST = os.getenv("POSTGRES_HOST")
    POSTGRES_PORT = int(os.getenv("POSTGRES_PORT"))
    KAFKA_BOOTSTRAP_SERVERS = os.getenv("KAFKA_BOOTSTRAP_SERVERS")
    KAFKA_SECURITY_PROTOCOL = os.getenv("KAFKA_SECURITY_PROTOCOL")
    NIFI_HOST = os.getenv("NIFI_HOST")
    NIFI_USERNAME = os.getenv("NIFI_USERNAME")
    NIFI_PASSWORD = os.getenv("NIFI_PASSWORD")
    MINIO_SERVER = os.getenv("MINIO_SERVER")
    MINIO_ROOT_USER = os.getenv("MINIO_ROOT_USER")
    MINIO_ROOT_PASSWORD = os.getenv("MINIO_ROOT_PASSWORD")
    MINIO_USER = os.getenv("MINIO_USER")
    MINIO_PASSWORD = os.getenv("MINIO_PASSWORD")


class DevSettings(BaseSettings):
    MINIO_BUCKET = os.getenv("MINIO_BUCKET_DEV")


class TestSettings(BaseSettings):
    MINIO_BUCKET = os.getenv("MINIO_BUCKET_TEST")


class ProdSettings(BaseSettings):
    MINIO_BUCKET = os.getenv("MINIO_BUCKET_PROD")


settings_map = {
    "DEV": DevSettings,
    "TEST": TestSettings,
    "PROD": ProdSettings
}


def get_settings(env="DEV"):
    return settings_map[env]()
