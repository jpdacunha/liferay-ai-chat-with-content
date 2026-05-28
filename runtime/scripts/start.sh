#!/usr/bin/env sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"

# GPU-only mode: fail fast if Docker cannot allocate a GPU.
if ! sudo docker run --rm --gpus all alpine:3.20 true >/dev/null 2>&1; then
	echo "ERROR: Docker GPU support is not active. GPU is required to start this stack."
	echo "Install/configure NVIDIA Container Toolkit (or Docker Desktop GPU support), then retry."
	exit 1
fi

echo "Starting full stack (build + up)..."
sudo docker compose up -d --build

echo "Stack is starting. Current service status:"
sudo docker compose ps
