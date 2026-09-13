#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "[deploy] Pull itClass web image..."
docker compose pull twschool-app-dev

echo "[deploy] Start itClass web..."
docker compose up -d twschool-app-dev

echo "[deploy] Check local page..."
for attempt in $(seq 1 20); do
  if curl --fail --silent --show-error http://127.0.0.1:4004/ >/dev/null; then
    echo "[deploy] itClass web is healthy."
    docker ps --filter name=twschool-app-dev
    exit 0
  fi
  sleep 2
done

echo "[deploy] itClass web did not become healthy in time." >&2
docker logs --tail=100 twschool-app-dev >&2
exit 1
