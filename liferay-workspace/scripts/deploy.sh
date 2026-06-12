#!/usr/bin/env sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"

echo "Executing deploy inside $REPO_ROOT"

echo "Copying client extensions to "$REPO_ROOT"/../runtime/liferay-74/mount/deploy"
cp -Rf "$REPO_ROOT"/build/docker/client-extensions/* "$REPO_ROOT"/../runtime/liferay-74/mount/deploy




