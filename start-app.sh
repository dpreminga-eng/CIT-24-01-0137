# start-app.sh
# Starts (or resumes) all service containers on the prepared
# network/volume, with a restart policy, and prints the access URL.

set -e

NETWORK_NAME="notes-network"
VOLUME_NAME="notes-db-data"
WEB_IMAGE="notes-web:latest"
DB_IMAGE="postgres:16-alpine"

DB_CONTAINER="notes-db"
WEB_CONTAINER="notes-web"

DB_NAME="notesdb"
DB_USER="notesuser"
DB_PASS="notespass"

HOST_PORT=5000

echo "Running app ..."

#Start (or create) the database container
if docker ps -a --format '{{.Names}}' | grep -q "^${DB_CONTAINER}$"; then
    echo "Starting existing db container ..."
    docker start "$DB_CONTAINER"
else
    echo "Creating db container ..."
    docker run -d \
        --name "$DB_CONTAINER" \
        --network "$NETWORK_NAME" \
        --restart unless-stopped \
        -e POSTGRES_DB="$DB_NAME" \
        -e POSTGRES_USER="$DB_USER" \
        -e POSTGRES_PASSWORD="$DB_PASS" \
        -v "$VOLUME_NAME":/var/lib/postgresql/data \
        "$DB_IMAGE"
fi

# Give Postgres a moment to accept connections
echo "Waiting for database to be ready ..."
sleep 5

# Start (or create) the web container
if docker ps -a --format '{{.Names}}' | grep -q "^${WEB_CONTAINER}$"; then
    echo "Starting existing web container ..."
    docker start "$WEB_CONTAINER"
else
    echo "Creating web container ..."
    docker run -d \
        --name "$WEB_CONTAINER" \
        --network "$NETWORK_NAME" \
        --restart unless-stopped \
        -e DB_HOST="$DB_CONTAINER" \
        -e DB_NAME="$DB_NAME" \
        -e DB_USER="$DB_USER" \
        -e DB_PASS="$DB_PASS" \
        -p "${HOST_PORT}:5000" \
        "$WEB_IMAGE"
fi

echo ""
echo "The app is available at http://localhost:${HOST_PORT}"
