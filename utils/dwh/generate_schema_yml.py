import os
import psycopg2
import yaml
from app import get_settings

def generate_schema_yml(
    schema: str,
    yml_path_template: str = "dbt/models/{schema}/schema.yml",
    env: str = "DEV"
) -> None:
    """
    Generate or update a dbt schema.yml file for existing tables in a given schema.

    :param schema: Database schema name (e.g. "stg", "meta", etc.)
    :param yml_path_template: Path template for schema.yml file (default: dbt/models/{schema}/schema.yml)
    :param env: Environment name passed to get_settings (e.g. "DEV", "PROD")
    """

    settings = get_settings(env)

    conn = psycopg2.connect(
        dbname=settings.POSTGRES_DB,
        user=settings.POSTGRES_USER,
        password=settings.POSTGRES_PASSWORD,
        host=settings.POSTGRES_HOST,
        port=settings.POSTGRES_PORT
    )

    with conn.cursor() as cur:
        cur.execute(
            "SELECT table_name FROM information_schema.tables WHERE table_schema = %s AND table_type = 'BASE TABLE'",
            (schema,)
        )
        tables = [row[0] for row in cur.fetchall()]

    yml_content = {
        "version": 2,
        "sources": [
            {
                "name": schema,
                "schema": schema,
                "tables": [{"name": t} for t in tables]
            }
        ]
    }

    output_path = yml_path_template.format(schema=schema)
    os.makedirs(os.path.dirname(output_path), exist_ok=True)

    with open(output_path, "w") as f:
        yaml.dump(yml_content, f, sort_keys=False)

    print(f"✅ schema.yml updated at: {output_path}")
