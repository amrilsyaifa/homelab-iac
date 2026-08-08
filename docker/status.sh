#!/usr/bin/env bash

set -euo pipefail

echo "Homelab containers:"
echo

docker ps \
  --filter "name=portainer" \
  --filter "name=minio" \
  --filter "name=registry" \
  --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"