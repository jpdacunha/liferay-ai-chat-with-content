#!/usr/bin/env sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"

echo "Stopping full stack..."
sudo docker compose down

echo "Stack stopped."
