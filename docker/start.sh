#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$BASE_DIR/create-network.sh"

services=(
  "portainer"
  "minio"
  "gitea"
  "registry"
)

for service in "${services[@]}"; do
  echo "Starting $service..."
  docker compose \
    --project-directory "$BASE_DIR/$service" \
    -f "$BASE_DIR/$service/compose.yaml" \
    up -d
done

echo
echo "All homelab Docker services started."