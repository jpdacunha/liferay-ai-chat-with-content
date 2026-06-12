#!/usr/bin/env sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"

# Nom du projet Compose courant (défini dans docker-compose.yml via "name:")
PROJECT_NAME="liferay-ai-chat-with-content"

# Liste des images déclarées par cette stack (avant down)
STACK_IMAGES="$(sudo docker compose config --images | sort -u)"

echo "Stopping and removing current stack containers/networks/volumes..."
sudo docker compose down --volumes --remove-orphans

echo "Removing only images from current stack, preserving other stacks usage..."
for image in $STACK_IMAGES; do
    # Si l'image n'existe déjà plus localement, on passe.
    if ! sudo docker image inspect "$image" >/dev/null 2>&1; then
        continue
    fi

    # Vérifie si des containers d'un AUTRE projet compose utilisent cette image.
    other_users="$(sudo docker ps -a \
        --filter "ancestor=$image" \
        --format '{{.Label "com.docker.compose.project"}}' \
        | grep -v "^$PROJECT_NAME$" | sort -u || true)"

    if [ -n "$other_users" ]; then
        echo "Keeping image $image (used by other compose project(s): $other_users)"
        continue
    fi

    echo "Removing image $image"
    sudo docker image rm "$image" >/dev/null 2>&1 || true
done

echo "Cleanup complete for project: $PROJECT_NAME"