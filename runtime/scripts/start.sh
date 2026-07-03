#!/usr/bin/env sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"

# Couleurs ANSI
RED='\033[0;31m'
BOLD_RED='\033[1;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# GPU check: do not block startup if Docker cannot allocate a GPU.
if ! sudo docker run --rm --gpus all alpine:3.20 true >/dev/null 2>&1; then
    echo ""
    echo "${BOLD_RED}============================================================${NC}"
    echo "${BOLD_RED} WARNING: DOCKER GPU / CUDA SUPPORT IS NOT ACTIVE${NC}"
    echo "${BOLD_RED}============================================================${NC}"
    echo "${RED}Docker was not able to allocate a GPU for the test container.${NC}"
    echo "${RED}The stack will continue to start, but GPU/CUDA-dependent services may fail or run in degraded mode.${NC}"
    echo ""
    echo "${YELLOW}Recommended checks:${NC}"
    echo "${YELLOW}- Verify NVIDIA drivers are installed and working${NC}"
    echo "${YELLOW}- Verify NVIDIA Container Toolkit is installed/configured${NC}"
    echo "${YELLOW}- Verify Docker Desktop GPU support if applicable${NC}"
    echo "${YELLOW}- Test manually with:${NC} sudo docker run --rm --gpus all alpine:3.20 true"
    echo "${BOLD_RED}============================================================${NC}"
    echo ""
fi

echo "Starting full stack (build + up)..."
sudo docker compose up -d --build

echo "Stack is starting. Current service status:"
sudo docker compose ps
