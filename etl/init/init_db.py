from psycopg2 import connect
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
from app import get_settings

SCHEMAS = ["stg", "dds", "rep", "meta"]


def create_schemas(conn):
    with conn.cursor() as cur:
        for schema in SCHEMAS:
            cur.execute(f"CREATE SCHEMA IF NOT EXISTS {schema};")
            print(f"✅ Schema '{schema}' created (if not exists).")
    conn.commit()


if __name__ == "__main__":
    settings = get_settings()

    conn = connect(
        dbname=settings.POSTGRES_DB,
        user=settings.POSTGRES_USER,
        password=settings.POSTGRES_PASSWORD,
        host=settings.POSTGRES_HOST,
        port=5432
    )
    conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)

    create_schemas(conn)
    conn.close()
    print("✅ All schemas created.")
