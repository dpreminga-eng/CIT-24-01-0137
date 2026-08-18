# prepare-app.sh
# Builds custom images and creates the network + named volume
# required by the application. Safe to re-run.

set -e

NETWORK_NAME="notes-network"
VOLUME_NAME="notes-db-data"
WEB_IMAGE="notes-web:latest"

echo "Preparing app ..."

# Build custom web image
echo "Building web image ($WEB_IMAGE) ..."
docker build -t "$WEB_IMAGE" ./app

# Create Docker network
if ! docker network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
    echo "Creating network: $NETWORK_NAME"
    docker network create "$NETWORK_NAME"
else
    echo "Network $NETWORK_NAME already exists, skipping."
fi

#Create named volume for Postgres persistent data
if ! docker volume inspect "$VOLUME_NAME" >/dev/null 2>&1; then
    echo "Creating volume: $VOLUME_NAME"
    docker volume create "$VOLUME_NAME"
else
    echo "Volume $VOLUME_NAME already exists, skipping."
fi

echo "Preparation complete."
