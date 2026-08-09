#!/usr/bin/env bash

set -euo pipefail

K3S_TARGET="/etc/rancher/k3s/registries.yaml"
K3S_BACKUP="${K3S_TARGET}.bak"

DOCKER_TARGET="/etc/docker/daemon.json"
DOCKER_BACKUP="${DOCKER_TARGET}.bak"

echo "======================================"
echo " Remove Homelab Registry Configuration"
echo "======================================"
echo

# ---------------------------------------
# k3s
# ---------------------------------------

echo "[1/3] Removing k3s registry configuration..."

if [[ -f "$K3S_BACKUP" ]]; then
  sudo mv "$K3S_BACKUP" "$K3S_TARGET"
  echo "  Previous k3s configuration restored."

elif [[ -f "$K3S_TARGET" ]]; then
  sudo rm "$K3S_TARGET"
  echo "  $K3S_TARGET removed."

else
  echo "  No k3s registry configuration found."
fi

# ---------------------------------------
# Docker
# ---------------------------------------

echo
echo "[2/3] Removing Docker configuration..."

if [[ -f "$DOCKER_BACKUP" ]]; then
  sudo mv "$DOCKER_BACKUP" "$DOCKER_TARGET"
  echo "  Previous Docker configuration restored."

elif [[ -f "$DOCKER_TARGET" ]]; then
  sudo rm "$DOCKER_TARGET"
  echo "  $DOCKER_TARGET removed."

else
  echo "  No Docker configuration found."
fi

# ---------------------------------------
# Restart
# ---------------------------------------

echo
echo "[3/3] Restarting services..."

if systemctl is-active --quiet docker; then
  sudo systemctl restart docker
  echo "  Docker restarted."
fi

if systemctl is-active --quiet k3s; then
  sudo systemctl restart k3s
  echo "  k3s restarted."
fi

echo
echo "======================================"
echo " Configuration removed successfully."
echo "======================================"