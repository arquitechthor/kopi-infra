#!/bin/bash
# Bootstrap Kopi Tools for local development (Docker Compose).
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_DIR="$SCRIPT_DIR/../docker/compose"
ENV_FILE="$COMPOSE_DIR/.env"
ENV_EXAMPLE="$COMPOSE_DIR/.env.example"

echo "=== Kopi Tools — Local Bootstrap ==="
echo ""

# ── Prerequisites check ────────────────────────────────────────────────────
command -v docker >/dev/null 2>&1 || { echo "ERROR: Docker is not installed."; exit 1; }
docker compose version >/dev/null 2>&1 || { echo "ERROR: Docker Compose v2 is not available."; exit 1; }

# ── .env setup ────────────────────────────────────────────────────────────
if [ ! -f "$ENV_FILE" ]; then
    echo "Creating .env from .env.example..."
    cp "$ENV_EXAMPLE" "$ENV_FILE"
    echo ""
    echo "IMPORTANT: Edit docker/compose/.env before continuing."
    echo "  Set JWT_SECRET to a random string of at least 32 characters."
    echo "  Example: openssl rand -base64 48"
    echo ""
    read -p "Press Enter once you have configured .env..."
fi

# ── Start stack ────────────────────────────────────────────────────────────
echo "Starting stack..."
docker compose -f "$COMPOSE_DIR/docker-compose.yml" up --build -d

echo ""
echo "Stack is running:"
echo "  Frontend  → http://localhost:4200"
echo "  Gateway   → http://localhost:8080"
echo "  Auth      → http://localhost:8081"
echo "  Links     → http://localhost:8082"
echo "  Tasks     → http://localhost:8083"
echo ""
echo "Run 'kopi status' to check service health."
