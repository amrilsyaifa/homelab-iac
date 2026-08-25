#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

K3S_SOURCE="$SCRIPT_DIR/registries.yaml"
K3S_TARGET="/etc/rancher/k3s/registries.yaml"

DOCKER_SOURCE="$PROJECT_DIR/docker/daemon.json"
DOCKER_TARGET="/etc/docker/daemon.json"

echo "======================================"
echo " Homelab Registry Configuration"
echo "======================================"
echo

# ---------------------------------------
# Check source files
# ---------------------------------------

if [[ ! -f "$K3S_SOURCE" ]]; then
  echo "ERROR: $K3S_SOURCE not found."
  exit 1
fi

if [[ ! -f "$DOCKER_SOURCE" ]]; then
  echo "ERROR: $DOCKER_SOURCE not found."
  exit 1
fi

# ---------------------------------------
# Backup existing configuration
# ---------------------------------------

echo "[1/5] Backing up existing configuration..."

if [[ -f "$K3S_TARGET" ]]; then
  sudo cp "$K3S_TARGET" "${K3S_TARGET}.bak"
  echo "  Backed up $K3S_TARGET"
fi

if [[ -f "$DOCKER_TARGET" ]]; then
  sudo cp "$DOCKER_TARGET" "${DOCKER_TARGET}.bak"
  echo "  Backed up $DOCKER_TARGET"
fi

# ---------------------------------------
# Install Docker configuration
# ---------------------------------------

echo
echo "[2/5] Installing Docker configuration..."

sudo mkdir -p /etc/docker

sudo install \
  -m 644 \
  "$DOCKER_SOURCE" \
  "$DOCKER_TARGET"

echo "  Installed $DOCKER_TARGET"

# ---------------------------------------
# Install k3s registry configuration
# ---------------------------------------

echo
echo "[3/5] Installing k3s registry configuration..."

sudo mkdir -p /etc/rancher/k3s

sudo install \
  -m 644 \
  "$K3S_SOURCE" \
  "$K3S_TARGET"

echo "  Installed $K3S_TARGET"

# ---------------------------------------
# Restart services
# ---------------------------------------

echo
echo "[4/5] Restarting services..."

if systemctl is-active --quiet docker; then
  sudo systemctl restart docker
  echo "  Docker restarted."
else
  echo "  Docker is not running. Skipping."
fi

if systemctl is-active --quiet k3s; then
  sudo systemctl restart k3s
  echo "  k3s restarted."
else
  echo "  k3s is not running. Skipping."
fi

# ---------------------------------------
# Verification
# ---------------------------------------

echo
echo "[5/5] Verification..."

if command -v docker >/dev/null 2>&1; then
  echo
  echo "Docker insecure registries:"
  docker info 2>/dev/null | grep -A 10 "Insecure Registries" || true
fi

if command -v k3s >/dev/null 2>&1; then
  echo
  echo "k3s nodes:"
  sudo k3s kubectl get nodes || true
fi

echo
echo "======================================"
echo " Configuration installed successfully."
echo "======================================"