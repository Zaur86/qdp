import sys
import psycopg2
from app import get_settings

if len(sys.argv) != 3:
    print("Usage: python utils/dwh/clean_schema.py <ENV> <SCHEMA_NAME>")
    sys.exit(1)

env = sys.argv[1].upper()
schema_name = sys.argv[2]

settings = get_settings(env)

print(f"⚠️ WARNING: This will permanently drop ALL tables in schema '{schema_name}' in {env} environment.")
confirm = input("Type 'yes' to confirm: ").strip().lower()
if confirm != "yes":
    print("❌ Operation cancelled.")
    sys.exit(0)

conn = psycopg2.connect(
    dbname=settings.POSTGRES_DB,
    user=settings.POSTGRES_USER,
    password=settings.POSTGRES_PASSWORD,
    host=settings.POSTGRES_HOST,
    port=settings.POSTGRES_PORT
)
conn.autocommit = True

try:
    with conn.cursor() as cur:
        cur.execute(f"""
            DO
            $$
            DECLARE
                r RECORD;
            BEGIN
                FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = '{schema_name}')
                LOOP
                    EXECUTE 'DROP TABLE IF EXISTS {schema_name}.' || quote_ident(r.tablename) || ' CASCADE';
                END LOOP;
            END
            $$;
        """)
        print(f"✅ All tables in schema '{schema_name}' have been dropped.")
except Exception as e:
    print("⚠️ Error while dropping tables:", e)
finally:
    conn.close()
