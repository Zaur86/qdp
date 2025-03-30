#!/bin/bash

# Загрузить переменные из .env
set -a
source .env
set +a

BROKER="$KAFKA_BOOTSTRAP_SERVERS"
TOPIC_DIR="smoke_tests/kafka"

echo "📤 Sending smoke test messages to Kafka at $BROKER..."

for file in "$TOPIC_DIR"/*.json; do
  topic=$(basename "$file" .json)
  echo "→ Sending to topic: $topic from file: $file"

  jq -c '.[]' "$file" | while read -r msg; do
    echo "$msg" | kcat -b "$BROKER" -t "$topic" -P
  done

  echo "✅ Done with $topic"
done
