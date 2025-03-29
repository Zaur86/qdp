import sys
from psycopg2 import connect, sql
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT


try:
    from app import get_settings
except Exception as e:
    print(f"❌ Failed to import settings: {e}")
    sys.exit(1)

def execute_sql_file(conn, path):
    try:
        with open(path, "r", encoding="utf-8") as f:
            sql_code = f.read()
    except Exception as e:
        print(f"❌ Failed to read SQL file '{path}': {e}")
        sys.exit(1)

    with conn.cursor() as cur:
        cur.execute(sql.SQL(sql_code))
        print(f"✅ Executed SQL file: {path}")
    conn.commit()

def create_schema_if_not_exists(conn, schema):
    with conn.cursor() as cur:
        cur.execute(sql.SQL(f"CREATE SCHEMA IF NOT EXISTS {schema};"))
        print(f"✅ Schema '{schema}' ensured to exist.")
    conn.commit()

if __name__ == "__main__":
    print(f"Args received: {sys.argv}")

    if len(sys.argv) != 4:
        print("Usage: python etl/init/init_schema.py <enviroment> <schema_name> <sql_file_path>")
        sys.exit(1)

    env_mode = sys.argv[1]
    schema_name = sys.argv[2]
    sql_file = sys.argv[3]

    settings = get_settings(env=env_mode)

    try:
        conn = connect(
            dbname=settings.POSTGRES_DB,
            user=settings.POSTGRES_USER,
            password=settings.POSTGRES_PASSWORD,
            host=settings.POSTGRES_HOST,
            port=settings.POSTGRES_PORT
        )
        conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
    except Exception as e:
        print(f"❌ Failed to connect to database: {e}")
        sys.exit(1)

    create_schema_if_not_exists(conn, schema_name)
    execute_sql_file(conn, sql_file)

    conn.close()
    print("✅ Connection closed.")
