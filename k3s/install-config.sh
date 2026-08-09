#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing k3s configuration..."

sudo mkdir -p /etc/rancher/k3s

sudo install \
  -m 644 \
  "$SCRIPT_DIR/config.yaml" \
  /etc/rancher/k3s/config.yaml

sudo install \
  -m 644 \
  "$SCRIPT_DIR/registries.yaml" \
  /etc/rancher/k3s/registries.yaml

echo "Restarting k3s..."

sudo systemctl restart k3s

echo "Waiting for k3s..."

sleep 5

sudo k3s kubectl get nodes

echo
echo "k3s configuration installed."