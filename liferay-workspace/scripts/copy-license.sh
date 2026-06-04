#!/usr/bin/env sh
set -eu

usage() {
  echo "Usage: $0 [container-or-id]"
  echo ""
  echo "This script reads the license file path from .env:"
  echo "  LIFERAY_LICENSE_FILE_PATH=/path/to/license.xml"
  echo ""
  echo "Examples:"
  echo "  $0"
  echo "  $0 qls-ai-chatbot-liferay-1"
}

if [ "$#" -gt 1 ]; then
  usage
  exit 1
fi

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$REPO_ROOT/.env"

if [ -f "$ENV_FILE" ]; then
  # Export .env variables so the script can read them.
  set -a
  . "$ENV_FILE"
  set +a
fi

LICENSE_FILE="${LIFERAY_LICENSE_FILE_PATH:-}"
TARGET_CONTAINER="${1:-}"

if [ -z "$LICENSE_FILE" ]; then
  echo "Error: LIFERAY_LICENSE_FILE_PATH is not set in .env" >&2
  exit 1
fi

if [ ! -f "$LICENSE_FILE" ]; then
  echo "Error: license file not found: $LICENSE_FILE" >&2
  exit 1
fi

if [ -z "$TARGET_CONTAINER" ]; then
  TARGET_CONTAINER="$(sudo docker compose ps -q liferay)"

  if [ -z "$TARGET_CONTAINER" ]; then
    echo "Error: could not find running container for service 'liferay'." >&2
    echo "Start it first with: docker compose up -d liferay" >&2
    exit 1
  fi
fi

# Clean old licenses before copying new one
echo "Cleaning old licenses from $TARGET_CONTAINER ..."
sudo docker exec "$TARGET_CONTAINER" sh -c 'rm -f /opt/liferay/data/license/*.li'
sudo docker exec "$TARGET_CONTAINER" sh -c 'rm -f /opt/liferay/osgi/modules/*license*.xml /opt/liferay/osgi/modules/*activation*.xml'

DESTINATION_PATH="/opt/liferay/deploy"

echo "Copying '$LICENSE_FILE' to '$TARGET_CONTAINER:$DESTINATION_PATH'..."
sudo docker cp "$LICENSE_FILE" "$TARGET_CONTAINER:$DESTINATION_PATH"

echo "Done. License file copied successfully."

LIFERAY_CONTAINER="$(sudo docker ps --filter "name=liferay" --format '{{.Names}}' | head -n 1)"

if [ -n "$LIFERAY_CONTAINER" ]; then
	echo "Suivi des logs du conteneur Liferay: $LIFERAY_CONTAINER"
	sudo docker logs --follow "$LIFERAY_CONTAINER"
else
	echo "Aucun conteneur Liferay en cours d'execution trouve."
	echo "Demarrez les conteneurs puis relancez ce script pour suivre les logs."
fi
