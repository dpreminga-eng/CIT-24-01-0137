# Dockerized Notes App

This is my submission for Assignment 1 (CCS3308 - Virtualization and Containers). I built a small two-container web app to demonstrate the main things the assignment asks for: separate services in separate containers, communication between them over a Docker network, and one service keeping its state in a persistent volume.

## What the app does

It's a simple **Notes App** - you open it in your browser, type a note, and hit add. The note gets saved. You can also delete notes you don't need anymore. Nothing fancy, but it's enough to actually show the database persisting data across restarts, which is the point of the exercise.

There are two services:

1. **web** - a small Flask app that serves the page and handles adding/deleting notes. Runs on port `5000`.
2. **db** - a PostgreSQL database that actually stores the notes. It's not reachable from outside the container network, only the `web` service can talk to it.

## Deployment requirements

- Docker Engine (I used 20.10+, should work fine on anything reasonably recent)
- Docker Compose, but only if you want to run it that way instead of the scripts (optional)
- Bash (I wrote and tested the scripts on Ubuntu)

## Network and volume

- **Network:** `notes-network`, a normal Docker bridge network. Both containers sit on it, and `web` reaches the database just by using `notes-db` as the hostname - no need to expose the database's port to the host at all.
- **Volume:** `notes-db-data`, a named volume mounted at `/var/lib/postgresql/data` inside the db container. This is where Postgres actually keeps its files, so as long as I don't delete the volume, the notes survive stopping/removing/recreating the containers.

## How the containers are configured

| Setting | web | db |
|---|---|---|
| Image | built locally from `./app/Dockerfile` (`notes-web:latest`) | `postgres:16-alpine` from Docker Hub |
| Port | `5000` on host mapped to `5000` in container | not exposed to host, only reachable on the internal network |
| Restart policy | `unless-stopped` | `unless-stopped` |
| Configured via | env vars: `DB_HOST`, `DB_NAME`, `DB_USER`, `DB_PASS` | env vars: `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD` |
| Volume | none | `notes-db-data` mounted at `/var/lib/postgresql/data` |

## Containers

| Name | What it does |
|---|---|
| `notes-web` | the Flask app - UI and logic |
| `notes-db` | Postgres, holds all the notes |

## How to run it

I wrote plain Docker commands into the four scripts the assignment asks for, and also added a `docker-compose.yaml` since it was allowed as an optional extra.

### Using the scripts

```bash
chmod +x prepare-app.sh start-app.sh stop-app.sh remove-app.sh

./prepare-app.sh   # builds the web image, sets up the network and volume
./start-app.sh     # starts both containers
./stop-app.sh      # stops everything but keeps the data
./remove-app.sh    # tears it all down - containers, image, network, volume
```

`start-app.sh` checks if the containers already exist first - if they do it just starts them again instead of recreating them, so nothing gets wiped out by accident. Same idea in `prepare-app.sh` for the network and volume, they only get created if they're not already there.

### Using docker-compose instead

```bash
docker-compose build
docker-compose up -d
docker-compose stop
docker-compose down       # stops and removes containers, keeps the volume
docker-compose down -v    # also wipes the volume if you want a clean slate
```

### Opening the app

Once it's running, go to:

```
http://localhost:5000
```

Add notes with the text box, delete them with the button next to each one.

## Example run

```bash
./prepare-app.sh
Preparing app ...

./start-app.sh
Running app ...
The app is available at http://localhost:5000

# now open the browser and add a few notes

./stop-app.sh
Stopping app ...

./remove-app.sh
Removed app.
```

## A couple of things worth noting

- The web container waits a few seconds for Postgres to actually be ready before it starts hitting it, since the database container takes a moment to accept connections after it's created.
- All the actual note data lives in the `notes-db-data` volume, not in the containers themselves. So removing the containers (e.g. with `stop-app.sh` then starting them again, or even recreating them) doesn't touch the data - only `remove-app.sh` deletes the volume, and that's on purpose since it's meant to reset everything.
