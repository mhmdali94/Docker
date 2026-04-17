#!/bin/bash
#
# ============================================================
#   Plausible Analytics Auto-Installer
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
echo "  ║       Plausible Analytics Auto-Installer         ║"
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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E 'plausible' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing Plausible containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
PL_DIR="/root/docker/plausible"
if [ -d "$PL_DIR" ]; then
    warn "Removing old directory $PL_DIR..."
    rm -rf "$PL_DIR"
fi
mkdir -p "$PL_DIR"
cd "$PL_DIR" || error "Cannot navigate to $PL_DIR"
info "Directory ready: $PL_DIR"

section "Step 6: Generating Credentials & docker-compose.yml"
PL_DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 24)
PL_SECRET=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 64)
SERVER_IP_SETUP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
info "Credentials generated."
info "Admin account will be created on first visit."

cat > "$PL_DIR/docker-compose.yml" <<EOF
services:
  plausible-db:
    image: postgres:16-alpine
    container_name: plausible-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: plausible_db
      POSTGRES_USER: plausible
      POSTGRES_PASSWORD: $PL_DB_PASS
    volumes:
      - ./pgdata:/var/lib/postgresql/data
    networks:
      - plausible-net

  plausible-events-db:
    image: clickhouse/clickhouse-server:24.3-alpine
    container_name: plausible-events-db
    restart: unless-stopped
    volumes:
      - ./clickhouse-data:/var/lib/clickhouse
      - ./clickhouse-logs:/var/log/clickhouse-server
    ulimits:
      nofile:
        soft: 262144
        hard: 262144
    networks:
      - plausible-net

  plausible:
    image: ghcr.io/plausible/community-edition:v2
    container_name: plausible
    restart: unless-stopped
    command: sh -c "sleep 10 && /entrypoint.sh db createdb && /entrypoint.sh db migrate && /entrypoint.sh run"
    depends_on:
      - plausible-db
      - plausible-events-db
    ports:
      - "8100:8000"
    environment:
      BASE_URL: http://$SERVER_IP_SETUP:8100
      SECRET_KEY_BASE: $PL_SECRET
      DATABASE_URL: postgres://plausible:$PL_DB_PASS@plausible-db:5432/plausible_db
      CLICKHOUSE_DATABASE_URL: http://plausible-events-db:8123/plausible_events_db
      DISABLE_REGISTRATION: invite_only
    networks:
      - plausible-net

networks:
  plausible-net:
    driver: bridge
EOF
info "docker-compose.yml created."

section "Step 7: Starting Plausible"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 8: Verifying Containers"
sleep 15
RUNNING=$(docker ps --format '{{.Names}}' | grep -E 'plausible' || true)
if [ -z "$RUNNING" ]; then
    warn "Containers may not have started. Check: docker logs plausible"
else
    info "Containers running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for Plausible to be ready on port 8100 (may take a few minutes)..."
HEALTH_OK=0
for i in $(seq 1 24); do
    if curl -sf --max-time 5 http://127.0.0.1:8100 &>/dev/null; then
        info "Port 8100 is responding — Plausible is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/24 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 8100 2>/dev/null; then
        warn "Port 8100 is open but HTTP did not respond. Still initializing."
        warn "Check logs: docker logs plausible"
    else
        warn "Port 8100 is NOT responding after 120s."
        warn "Check logs: docker logs plausible"
        docker logs --tail 20 plausible 2>&1 || true
    fi
fi

section "Step 10: Opening Firewall Port 8100"
if command -v ufw &> /dev/null; then
    ufw allow 8100/tcp
    info "UFW: port 8100/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Plausible in your browser:               ║"
echo "  ║      👉  http://$SERVER_IP:8100"
echo "  ║                                                      ║"
echo "  ║  🔑  Create your admin account on first visit.     ║"
echo "  ║                                                      ║"
echo "  ║  📊  Then add your website and embed the           ║"
echo "  ║      tracking script in your pages.                 ║"
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
