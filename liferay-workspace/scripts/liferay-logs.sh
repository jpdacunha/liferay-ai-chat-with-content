#!/usr/bin/env sh

LIFERAY_CONTAINER="$(sudo docker ps --filter "name=liferay-ai-chat-with-content-liferay-1" --format '{{.Names}}' | head -n 1)"

if [ -n "$LIFERAY_CONTAINER" ]; then
	echo "Following logs of Liferay container: $LIFERAY_CONTAINER"
	sudo docker logs --follow "$LIFERAY_CONTAINER"
else
	echo "No liferay container is currently running."
	echo "Start the containers and then rerun this script to follow the logs."
fi