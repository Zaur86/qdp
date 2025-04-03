#!/bin/bash

# Get ENV arg, fallback to DEV
ENV=${1:-DEV}
echo "🌍 Environment: $ENV"

# Load .env
set -a
source .env 2>/dev/null || true
set +a

# Construct DATABASE_URL from .env variables
DATABASE_URL="postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}"

SQL_DIR="smoke_tests/dbt/sql"

confirm_step() {
  while true; do
    read -rp "👉 $1 (Yes/No): " yn
    case $yn in
      [Yy][Ee][Ss] ) break;;
      [Nn][Oo] ) echo "🛑 Aborted by user."; exit;;
      * ) echo "❓ Please type Yes or No.";;
    esac
  done
}

echo "🚀 Starting DBT smoke test for target: $ENV"

confirm_step "Step 1: Insert first batch into stg.web__registrations?"
psql "$DATABASE_URL" -f "$SQL_DIR/01_fill_first_batch.sql"
echo "✅ First batch inserted."

confirm_step "Step 1.1: Run model dds.h__user?"
dbt run --target "$ENV" --profiles-dir dbt --project-dir dbt --no-write-json \
  --select dds.groups.hubs.h__user

confirm_step "Step 1.2: Run model dds.s__user__registration_channel?"
dbt run --target "$ENV" --profiles-dir dbt --project-dir dbt --no-write-json \
  --select dds.groups.satellites.s__user__registration_channel

confirm_step "Step 2: Insert second batch with duplicate user_id?"
psql "$DATABASE_URL" -f "$SQL_DIR/02_fill_second_batch.sql"
echo "✅ Second batch inserted."

confirm_step "Step 2.1: Re-run model dds.h__user?"
dbt run --target "$ENV" --profiles-dir dbt --project-dir dbt --no-write-json \
  --select dds.groups.hubs.h__user

confirm_step "Step 2.2: Re-run model dds.s__user__registration_channel?"
dbt run --target "$ENV" --profiles-dir dbt --project-dir dbt --no-write-json \
  --select dds.groups.satellites.s__user__registration_channel

echo "🎉 DBT smoke test completed for target: $ENV"
