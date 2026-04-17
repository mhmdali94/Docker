#!/bin/bash
#
# ============================================================
#   Immich Photo Management Auto-Installer
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
echo "  ║       Immich Photo Management Auto-Installer     ║"
echo "  ║       Made by: Mohammed Ali Elshikh | prismatechwork.com                ║"
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

section "Step 4: Cleaning Up Existing Containers"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E 'immich' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing Immich containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
IMMICH_DIR="/root/docker/immich"
if [ -d "$IMMICH_DIR" ]; then
    warn "Removing old directory $IMMICH_DIR..."
    rm -rf "$IMMICH_DIR"
fi
mkdir -p "$IMMICH_DIR/library" "$IMMICH_DIR/model-cache"
cd "$IMMICH_DIR" || error "Cannot navigate to $IMMICH_DIR"
info "Directory ready: $IMMICH_DIR"

section "Step 6: Generating Credentials"
DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)
info "Database password generated."

section "Step 7: Generating .env & docker-compose.yml"
cat > "$IMMICH_DIR/.env" <<EOF
UPLOAD_LOCATION=./library
IMMICH_VERSION=release
DB_PASSWORD=$DB_PASS
DB_USERNAME=postgres
DB_DATABASE_NAME=immich
EOF

cat > "$IMMICH_DIR/docker-compose.yml" <<EOF
services:
  immich-server:
    image: ghcr.io/immich-app/immich-server:release
    container_name: immich-server
    restart: unless-stopped
    ports:
      - "2283:2283"
    volumes:
      - ./library:/usr/src/app/upload
      - /etc/localtime:/etc/localtime:ro
    env_file: .env
    depends_on:
      - immich-redis
      - immich-db
    networks:
      - immich-net

  immich-machine-learning:
    image: ghcr.io/immich-app/immich-machine-learning:release
    container_name: immich-machine-learning
    restart: unless-stopped
    volumes:
      - ./model-cache:/cache
    env_file: .env
    networks:
      - immich-net

  immich-redis:
    image: redis:6.2-alpine
    container_name: immich-redis
    restart: unless-stopped
    networks:
      - immich-net

  immich-db:
    image: tensorchord/pgvecto-rs:pg14-v0.2.0
    container_name: immich-db
    restart: unless-stopped
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: $DB_PASS
      POSTGRES_DB: immich
      POSTGRES_INITDB_ARGS: "--data-checksums"
    volumes:
      - ./pgdata:/var/lib/postgresql/data
    networks:
      - immich-net

networks:
  immich-net:
    driver: bridge
EOF
info ".env and docker-compose.yml created."

section "Step 8: Starting Immich"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 9: Verifying Containers"
sleep 10
RUNNING=$(docker ps --format '{{.Names}}' | grep -E 'immich' || true)
if [ -z "$RUNNING" ]; then
    warn "Containers may not have started. Check: docker logs immich-server"
else
    info "Containers running: $RUNNING"
fi

section "Step 10: Health Check"
info "Waiting for Immich to be ready on port 2283 (may take a few minutes)..."
HEALTH_OK=0
for i in $(seq 1 24); do
    if curl -sf --max-time 5 http://127.0.0.1:2283/api/server-info/ping &>/dev/null; then
        info "Port 2283 is responding — Immich is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/24 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 2283 2>/dev/null; then
        warn "Port 2283 is open but API did not respond. Still initializing."
        warn "Check logs: docker logs immich-server"
    else
        warn "Port 2283 is NOT responding after 120s."
        warn "Check logs: docker logs immich-server"
        docker logs --tail 20 immich-server 2>&1 || true
    fi
fi

section "Step 11: Opening Firewall Port 2283"
if command -v ufw &> /dev/null; then
    ufw allow 2283/tcp
    info "UFW: port 2283/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Immich in your browser:                  ║"
echo "  ║      👉  http://$SERVER_IP:2283"
echo "  ║                                                      ║"
echo "  ║  🔑  On first visit, create your admin account.   ║"
echo "  ║                                                      ║"
echo "  ║  📱  Mobile apps: iOS & Android available          ║"
echo "  ║      Configure server URL: http://$SERVER_IP:2283"
echo "  ║                                                      ║"
echo "  ║  📂  Photos stored in: $IMMICH_DIR/library"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh | prismatechwork.com                   ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║                                                      ║"
echo "  ║  🚀  Need a production-ready setup?                 ║"
echo "  ║                                                      ║"
echo "  ║  Contact us for a hardened, secure, and             ║"
echo "  ║  fully configured production environment:           ║"
echo "  ║                                                      ║"
echo "  ║  👨‍💻  Mohammed Ali Elshikh                            ║"
echo "  ║  🌐  prismatechwork.com                              ║"
echo "  ║                                                      ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
