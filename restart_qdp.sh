#!/bin/bash

# Определяем базовую директорию
BASE_DIR="/home/zaur/disk/qdp"

echo "🔻 Останавливаем и удаляем контейнеры..."
docker-compose down -v --remove-orphans

echo "🗑 Удаляем все данные и папки..."
sudo rm -rf "$BASE_DIR"/{nifi,airflow,minio,postgres,zookeeper,kafka}

echo "📂 Создаем нужные папки..."
mkdir -p "$BASE_DIR/nifi"
mkdir -p "$BASE_DIR/nifi/conf"
mkdir -p "$BASE_DIR/nifi/data"
mkdir -p "$BASE_DIR/nifi/work"
mkdir -p "$BASE_DIR/nifi/database_repository"
mkdir -p "$BASE_DIR/nifi/flowfile_repository"
mkdir -p "$BASE_DIR/nifi/content_repository"
mkdir -p "$BASE_DIR/nifi/provenance_repository"
mkdir -p "$BASE_DIR/nifi/logs"
mkdir -p "$BASE_DIR/airflow/dags"
mkdir -p "$BASE_DIR/airflow/logs"
mkdir -p "$BASE_DIR/airflow/plugins"
mkdir -p "$BASE_DIR/airflow/scripts"
mkdir -p "$BASE_DIR/postgres"
mkdir -p "$BASE_DIR/postgres/data"
mkdir -p "$BASE_DIR/zookeeper"
mkdir -p "$BASE_DIR/zookeeper/data"
mkdir -p "$BASE_DIR/kafka"
mkdir -p "$BASE_DIR/kafka/data"
mkdir -p "$BASE_DIR/minio"
mkdir -p "$BASE_DIR/minio/data"

echo "🔑 Исправляем права на папки..."
sudo chmod -R 777 "$BASE_DIR/airflow/logs"
sudo chown -R 50000:50000 "$BASE_DIR/airflow"

echo "🚀 Запускаем контейнеры..."
docker-compose --env-file .env up -d

echo "✅ Все контейнеры перезапущены!"
docker ps
