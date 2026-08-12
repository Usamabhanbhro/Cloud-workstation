#!/usr/bin/env bash
set -euo pipefail

if [[ $# -eq 0 ]]; then
    echo "Usage: sysinstall <package1> [package2 ...]"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_FILE="${SCRIPT_DIR}/../workstation/packages.txt"

echo "==> Installing packages: $*"
sudo apt-get update -y
sudo apt-get install -y "$@"

echo "==> Updating workstation/packages.txt..."
mkdir -p "$(dirname "$PACKAGES_FILE")"
touch "$PACKAGES_FILE"

for pkg in "$@"; do
    echo "$pkg" >> "$PACKAGES_FILE"
done

# Sort and remove duplicate entries
sort -u "$PACKAGES_FILE" -o "$PACKAGES_FILE"

echo "==> Done. Current packages in list:"
cat "$PACKAGES_FILE"
