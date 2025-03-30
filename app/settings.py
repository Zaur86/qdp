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


class DevSettings(BaseSettings):
    pass


class TestSettings(BaseSettings):
    pass


class ProdSettings(BaseSettings):
    pass


settings_map = {
    "DEV": DevSettings,
    "TEST": TestSettings,
    "PROD": ProdSettings
}


def get_settings(env="DEV"):
    return settings_map[env]()
