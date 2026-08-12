#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "==> Updating system package lists..."
sudo apt-get update -y

echo "==> Installing base runner tools..."
sudo apt-get install -y --no-install-recommends \
    tmux \
    ttyd \
    curl \
    wget \
    git \
    jq \
    ca-certificates

# Install custom user packages if packages.txt exists and is non-empty
PACKAGES_FILE="$(dirname "$0")/../workstation/packages.txt"
if [[ -f "$PACKAGES_FILE" && -s "$PACKAGES_FILE" ]]; then
    echo "==> Installing packages from workstation/packages.txt..."
    xargs -a "$PACKAGES_FILE" sudo apt-get install -y --no-install-recommends
fi
