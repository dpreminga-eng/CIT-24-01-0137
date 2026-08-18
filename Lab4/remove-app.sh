# remove-app.sh
# Removes ALL resources created by prepare-app.sh and start-app.sh:
# containers, the custom image, the network, and the named volume.
# This resets the application to a clean slate (data will be lost).

set -e

NETWORK_NAME="notes-network"
VOLUME_NAME="notes-db-data"
WEB_IMAGE="notes-web:latest"

DB_CONTAINER="notes-db"
WEB_CONTAINER="notes-web"

echo "Removing app resources ..."

#Remove containers (stop first if running)
for c in "$WEB_CONTAINER" "$DB_CONTAINER"; do
    if docker ps -a --format '{{.Names}}' | grep -q "^${c}$"; then
        echo "Removing container: $c"
        docker rm -f "$c"
    fi
done

#Remove custom image
if docker image inspect "$WEB_IMAGE" >/dev/null 2>&1; then
    echo "Removing image: $WEB_IMAGE"
    docker rmi "$WEB_IMAGE"
fi

#Remove network
if docker network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
    echo "Removing network: $NETWORK_NAME"
    docker network rm "$NETWORK_NAME"
fi

#Remove volume (this deletes persisted data)
if docker volume inspect "$VOLUME_NAME" >/dev/null 2>&1; then
    echo "Removing volume: $VOLUME_NAME"
    docker volume rm "$VOLUME_NAME"
fi

echo "Removed app."
