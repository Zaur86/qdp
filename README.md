# QDP Project

## Overview

QDP is designed to quickly build, deploy, and manage robust and automated data pipelines. The project leverages Apache Airflow, Apache Kafka, PostgreSQL, DBT, and Apache NiFi to streamline data ingestion, transformation, and delivery processes.

## Repository Description

- **app/**  
  Core application settings and common configurations used throughout the project.

- **dbt/**  
  Contains DBT models and configurations used for structured SQL data transformations. It follows a layered modeling approach:
  - **stg/** (staging layer): Raw data preparation and initial transformations.
  - **dds/** (Data Vault): Data Vault 2.0 structures (hubs and satellites) for long-term historical data storage.
  - **rep/** (reporting layer): Aggregations and models optimized for analytics and reporting.
  - **meta/**: Models and metadata structures for controlling data pipeline checkpoints and integrity.

- **docker-compose.yml**  
  Defines the Docker Compose configuration for rapidly deploying the full set of project services (Airflow, Kafka, PostgreSQL, MinIO, NiFi, etc.).

- **etl/**  
  Contains scripts and configurations used for initializing and managing data infrastructure:
  - **init/**: Initial setup scripts for databases and Kafka topic creation.
  - **services/**: Python utilities for dynamically generating NiFi data flows and etc.

- **requirements.txt**  
  Specifies Python dependencies required for running project scripts and services.

- **restart_qdp.sh**  
  Convenience script for quickly restarting Docker Compose services.

- **smoke_tests/**  
  Test scenarios and scripts for validating the setup and functionality of DBT models and Kafka topics:
  - Includes prepared test data for Kafka topics and SQL scripts for populating initial DBT data.

- **tmp/**  
  Directory for temporary storage, interactive experiments, and working scripts.

- **utils/**  
  Utility scripts for maintenance and automation tasks:
  - **dwh/**: Scripts for generating schema documentation and cleaning PostgreSQL schemas.
  - **kafka/**: Kafka management scripts (e.g., topic deletion).

## Quick Start

Ensure the `.env` file is configured based on the provided `.env.example`.

Set up Python virtual environment and install dependencies:

```bash
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

Then run:

```bash
docker-compose up -d
python etl/init/init_db.py
python etl/init/init_schema.py DEV dds etl/init/sql/dds_schema.sql
python etl/init/init_schema.py DEV stg etl/init/sql/stg__web__schema.sql
python etl/init/init_schema.py DEV meta etl/init/sql/meta__data_checkpoints.sql
python etl/init/create_kafka_topics.py
bash smoke_tests/run_dbt_smoke.sh dev
bash smoke_tests/run_kafka_smoke.sh dev
```
