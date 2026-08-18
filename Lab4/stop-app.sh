# stop-app.sh
# Stops all service containers WITHOUT removing them, the network,
# or the volume - so state and configuration are preserved and the
# app can be restarted later with start-app.sh.

set -e

DB_CONTAINER="notes-db"
WEB_CONTAINER="notes-web"

echo "Stopping app ..."

for c in "$WEB_CONTAINER" "$DB_CONTAINER"; do
    if docker ps --format '{{.Names}}' | grep -q "^${c}$"; then
        echo "Stopping $c ..."
        docker stop "$c"
    else
        echo "$c is not running."
    fi
done

echo "App stopped. Data and configuration have been preserved."
