#!/usr/bin/env sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"

blade gw build

echo "Copying client extensions to "$REPO_ROOT"/../runtime/liferay-74/mount/deploy"
cp -Rf "$REPO_ROOT"/build/docker/client-extensions/* "$REPO_ROOT"/../runtime/liferay-74/mount/deploy

LIFERAY_CONTAINER="$(sudo docker ps --filter "name=liferay-ai-chat-with-content-liferay-1" --format '{{.Names}}' | head -n 1)"

if [ -n "$LIFERAY_CONTAINER" ]; then
	echo "Following logs of Liferay container: $LIFERAY_CONTAINER"
	sudo docker logs --follow "$LIFERAY_CONTAINER"
else
	echo "No liferay container is currently running."
	echo "Start the containers and then rerun this script to follow the logs."
fi



