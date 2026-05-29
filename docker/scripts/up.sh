#!/bin/bash
# Start the full Kopi Tools stack.
# Tip: use `kopi up` (kopi-cli) for a richer experience.
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_DIR="$SCRIPT_DIR/../compose"

echo "Starting Kopi Tools stack..."
docker compose -f "$COMPOSE_DIR/docker-compose.yml" up -d "$@"
echo "Stack running. Gateway → http://localhost:8080"
