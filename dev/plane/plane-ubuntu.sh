#!/bin/bash
#
# ============================================================
#   Plane Auto-Installer
#   Made by: Mohammed Ali Elshikh | prismatechwork.com
#
#   ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️
#   This script is NOT intended for production use.
# ============================================================

set -e

info()    { echo -e "\e[32m[INFO]\e[0m $*"; }
warn()    { echo -e "\e[33m[WARN]\e[0m $*"; }
error()   { echo -e "\e[31m[ERROR]\e[0m $*"; exit 1; }
section() { echo -e "\n\e[36m========== $* ==========\e[0m"; }

clear
echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║           Plane Auto-Installer                   ║"
echo "  ║           Made by: Mohammed Ali Elshikh         ║"
echo "  ║           prismatechwork.com                    ║"
echo "  ║                                                  ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️         ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║                                                      ║"
echo "  ║  ⚠️   DEMO / TESTING USE ONLY                        ║"
echo "  ║                                                      ║"
echo "  ║  This installer is intended for demo and testing.   ║"
echo "  ║  For a production-ready, hardened setup contact:    ║"
echo "  ║                                                      ║"
echo "  ║  👨‍💻  Mohammed Ali Elshikh                            ║"
echo "  ║  🌐  prismatechwork.com                              ║"
echo "  ║                                                      ║"
echo "  ║  Press ENTER to continue with demo install...       ║"
echo "  ║  Press Ctrl+C to cancel.                            ║"
echo "  ║                                                      ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
read -rp "" _DEMO_CONFIRM

section "Step 0: Checking Privileges"
if [ "$EUID" -ne 0 ]; then error "Please run as root: sudo bash $0"; fi
info "Running as root. OK."

section "Step 1: Verifying OS"
[ -f /etc/os-release ] || error "Cannot determine OS."
. /etc/os-release
[ "$ID" = "ubuntu" ] || error "Only Ubuntu is supported. Found: $ID"
{ [ "$VERSION_ID" = "22.04" ] || [ "$VERSION_ID" = "24.04" ]; } || error "Only Ubuntu 22.04/24.04 supported. Found: $VERSION_ID"
info "OS check passed: Ubuntu $VERSION_ID"

section "Step 2: Checking Docker"
if ! command -v docker &> /dev/null; then
    warn "Docker not found. Installing..."
    apt update -y && apt install -y docker.io
    systemctl enable --now docker
    info "Docker installed."
else
    info "Docker: $(docker --version)"
fi

section "Step 3: Checking Docker Compose V2"
if ! docker compose version &> /dev/null; then
    warn "Docker Compose V2 not found. Installing..."
    apt update -y && apt install -y docker-compose-v2 || apt install -y docker-compose
    info "Docker Compose installed."
else
    info "Docker Compose: $(docker compose version)"
fi

PLANE_DIR="/root/docker/plane"
COMPOSE_FILE="$PLANE_DIR/docker-compose.yaml"
ENV_FILE="$PLANE_DIR/plane.env"
COMPOSE="docker compose -f $COMPOSE_FILE --env-file $ENV_FILE"

section "Step 4: Cleaning Up Existing Installation"
if [ -f "$COMPOSE_FILE" ]; then
    warn "Existing Plane installation found at $PLANE_DIR — tearing it down..."
    $COMPOSE down -v --remove-orphans 2>/dev/null || true
fi
# Catch containers left over from any older/other-format run of this installer
# (different compose project or hardcoded container_name) that "down" above
# wouldn't know about — otherwise their held ports collide with the new stack.
LEFTOVER=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^plane' || true)
if [ -n "$LEFTOVER" ]; then
    warn "Removing leftover Plane containers: $(echo "$LEFTOVER" | tr '\n' ' ')"
    echo "$LEFTOVER" | xargs -r docker rm -f &>/dev/null || true
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
if [ -d "$PLANE_DIR" ]; then
    warn "Removing old directory $PLANE_DIR..."
    rm -rf "$PLANE_DIR"
fi
mkdir -p "$PLANE_DIR"
cd "$PLANE_DIR" || error "Cannot navigate to $PLANE_DIR"
info "Directory ready: $PLANE_DIR"

section "Step 6: Fetching Official Plane Release & Generating Config"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
HTTP_PORT=8091
HTTPS_PORT=8443
FALLBACK_RELEASE="v1.4.2"
GH_REPO="makeplane/plane"

info "Checking latest Plane release..."
APP_RELEASE=$(curl -sSL "https://api.github.com/repos/$GH_REPO/releases/latest" | grep -o '"tag_name": "[^"]*"' | sed 's/"tag_name": "//;s/"//g')
if [ -z "$APP_RELEASE" ]; then
    warn "Could not determine the latest release — falling back to $FALLBACK_RELEASE"
    APP_RELEASE="$FALLBACK_RELEASE"
fi
info "Using Plane release: $APP_RELEASE"

RELEASE_URL="https://github.com/$GH_REPO/releases/download/$APP_RELEASE"

fetch_release_file() {
    local name="$1" dest="$2"
    curl -fsSL "$RELEASE_URL/$name" -o "$dest" || error "Failed to download $name from release $APP_RELEASE"
}

fetch_release_file "docker-compose.yml" "$COMPOSE_FILE"
fetch_release_file "variables.env" "$ENV_FILE"
info "Downloaded official docker-compose.yml and variables.env for $APP_RELEASE."

set_env() {
    local key="$1" value="$2"
    if grep -q "^${key}=" "$ENV_FILE"; then
        sed -i "s|^${key}=.*|${key}=${value}|" "$ENV_FILE"
    else
        echo "${key}=${value}" >> "$ENV_FILE"
    fi
}

SECRET_KEY=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 50)
LIVE_SECRET_KEY=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 50)
MINIO_USER=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 12)
MINIO_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)

# Postgres/RabbitMQ credentials are left at their shipped defaults on purpose:
# neither service publishes a host port, so they're only reachable inside the
# compose network, and each has a same-named *_URL fallback baked into the
# official compose that must match — changing one without the other breaks auth.
set_env "APP_RELEASE" "$APP_RELEASE"
set_env "APP_DOMAIN" "$SERVER_IP:$HTTP_PORT"
set_env "LISTEN_HTTP_PORT" "$HTTP_PORT"
set_env "LISTEN_HTTPS_PORT" "$HTTPS_PORT"
# SITE_ADDRESS is Caddy's *internal* listen address inside the container, where
# the compose file always maps target:80/443 regardless of the external
# LISTEN_HTTP_PORT/LISTEN_HTTPS_PORT — it must stay :80, not the external port,
# or Docker forwards to a port nothing is listening on (connection reset).
set_env "SITE_ADDRESS" ":80"
set_env "SECRET_KEY" "$SECRET_KEY"
set_env "LIVE_SERVER_SECRET_KEY" "$LIVE_SECRET_KEY"
set_env "AWS_ACCESS_KEY_ID" "$MINIO_USER"
set_env "AWS_SECRET_ACCESS_KEY" "$MINIO_PASS"
info "Credentials generated and applied to plane.env."

section "Step 7: Starting Plane"
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    if $COMPOSE up -d; then
        break
    fi
    warn "Failed to start on attempt $attempt/$MAX_RETRIES (registry may be temporarily unavailable)."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed to start after $MAX_RETRIES attempts. Run manually: cd $PLANE_DIR && docker compose --env-file plane.env up -d"
done

section "Step 8: Waiting for Database Migrations"
MIGRATOR_ID=$($COMPOSE ps -q migrator 2>/dev/null || true)
if [ -n "$MIGRATOR_ID" ]; then
    info "Waiting for the one-shot migrator service to finish..."
    while [ "$(docker inspect --format='{{.State.Status}}' "$MIGRATOR_ID" 2>/dev/null)" = "running" ]; do
        sleep 2
    done
    MIGRATOR_EXIT=$(docker inspect --format='{{.State.ExitCode}}' "$MIGRATOR_ID" 2>/dev/null || echo 1)
    if [ "$MIGRATOR_EXIT" != "0" ]; then
        warn "Migrations failed (exit code $MIGRATOR_EXIT). Recent migrator logs:"
        docker logs --tail 30 "$MIGRATOR_ID" 2>&1 || true
        error "Aborting — migrations did not complete successfully."
    fi
    info "Migrations completed successfully."
else
    warn "Could not find the migrator container — skipping this check."
fi

section "Step 9: Health Check"
API_ID=$($COMPOSE ps -q api 2>/dev/null || true)
HEALTH_OK=0
if [ -n "$API_ID" ]; then
    info "Waiting for the API service to become ready..."
    for i in $(seq 1 30); do
        if docker exec "$API_ID" python3 -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/', timeout=3)" &>/dev/null; then
            info "API service is ready."
            HEALTH_OK=1
            break
        fi
        echo -n "  Attempt $i/30 — waiting 5s..."
        sleep 5
        echo " retrying"
    done
fi
if [ "$HEALTH_OK" -eq 0 ]; then
    warn "API did not respond in time. Check: docker logs $API_ID"
fi

info "Checking public URL..."
if curl -s --max-time 5 "http://127.0.0.1:$HTTP_PORT" &>/dev/null; then
    info "Port $HTTP_PORT is responding — Plane is healthy. ✅"
else
    PROXY_ID=$($COMPOSE ps -q proxy 2>/dev/null || true)
    warn "Port $HTTP_PORT is NOT responding yet."
    warn "Check logs: docker logs $PROXY_ID"
fi

section "Step 10: Opening Firewall Port $HTTP_PORT"
if command -v ufw &> /dev/null; then
    ufw allow "$HTTP_PORT"/tcp
    info "UFW: port $HTTP_PORT/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Plane in your browser:                  ║"
echo "  ║      👉  http://$SERVER_IP:$HTTP_PORT"
echo "  ║                                                      ║"
echo "  ║  🔑  Create your workspace on first visit.         ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║                                                      ║"
echo "  ║  🚀  Need production setup?                         ║"
echo "  ║      👨‍💻  Mohammed Ali Elshikh                      ║"
echo "  ║      🌐  prismatechwork.com                         ║"
echo "  ║                                                      ║"
echo "  ║  ☕  Support this script — USDT (TRC-20 only):     ║"
echo "  ║      TCSZTkXvhibdrFre5sdTsFLRQ6d6yQkd2i           ║"
echo "  ║                                                      ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
