#!/bin/bash
# Full reset: stop stack, delete all volumes (database data), rebuild and start.
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_DIR="$SCRIPT_DIR/../compose"

echo "WARNING: This will delete all database data."
read -p "Continue? (y/N) " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

echo "Stopping and removing volumes..."
docker compose -f "$COMPOSE_DIR/docker-compose.yml" down --volumes

echo "Rebuilding and starting..."
docker compose -f "$COMPOSE_DIR/docker-compose.yml" up --build -d

echo "Done. Stack is running."
