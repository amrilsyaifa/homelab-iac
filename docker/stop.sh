#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

services=(
  "registry"
  "minio"
  "portainer"
)

for service in "${services[@]}"; do
  echo "Stopping $service..."
  docker compose \
    --project-directory "$BASE_DIR/$service" \
    -f "$BASE_DIR/$service/compose.yaml" \
    down
done

echo
echo "All homelab Docker services stopped."