#!/bin/bash
# Stop the Kopi Tools stack.
# Pass --volumes / -v to also remove database data.
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_DIR="$SCRIPT_DIR/../compose"

docker compose -f "$COMPOSE_DIR/docker-compose.yml" down "$@"
