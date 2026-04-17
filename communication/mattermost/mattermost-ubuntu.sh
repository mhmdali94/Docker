#!/bin/bash
#
# ============================================================
#   Mattermost Team Messaging Auto-Installer
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
echo "  ║       Mattermost Team Messaging Auto-Installer   ║"
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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E 'mattermost' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing Mattermost containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
MM_DIR="/root/docker/mattermost"
if [ -d "$MM_DIR" ]; then
    warn "Removing old directory $MM_DIR..."
    rm -rf "$MM_DIR"
fi
mkdir -p "$MM_DIR/config" "$MM_DIR/data" "$MM_DIR/logs" "$MM_DIR/plugins" "$MM_DIR/client-plugins"
chown -R 2000:2000 "$MM_DIR/config" "$MM_DIR/data" "$MM_DIR/logs" "$MM_DIR/plugins" "$MM_DIR/client-plugins"
cd "$MM_DIR" || error "Cannot navigate to $MM_DIR"
info "Directory ready: $MM_DIR"

section "Step 6: Generating Credentials & docker-compose.yml"
MM_DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 24)
info "Database password generated."

cat > "$MM_DIR/docker-compose.yml" <<EOF
services:
  mattermost-db:
    image: postgres:15-alpine
    container_name: mattermost-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: mattermost
      POSTGRES_USER: mattermost
      POSTGRES_PASSWORD: $MM_DB_PASS
    volumes:
      - ./pgdata:/var/lib/postgresql/data
    networks:
      - mattermost-net

  mattermost:
    image: mattermost/mattermost-team-edition:latest
    container_name: mattermost
    restart: unless-stopped
    depends_on:
      - mattermost-db
    ports:
      - "8065:8065"
      - "8067:8067"
    environment:
      MM_SQLSETTINGS_DRIVERNAME: postgres
      MM_SQLSETTINGS_DATASOURCE: postgres://mattermost:$MM_DB_PASS@mattermost-db:5432/mattermost?sslmode=disable
      MM_BLEVESETTINGS_INDEXDIR: /mattermost/bleve-indexes
      MM_SERVICESETTINGS_SITEURL: ""
    volumes:
      - ./config:/mattermost/config
      - ./data:/mattermost/data
      - ./logs:/mattermost/logs
      - ./plugins:/mattermost/plugins
      - ./client-plugins:/mattermost/client/plugins
    networks:
      - mattermost-net

networks:
  mattermost-net:
    driver: bridge
EOF
info "docker-compose.yml created."

section "Step 7: Starting Mattermost"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 8: Verifying Containers"
sleep 10
RUNNING=$(docker ps --format '{{.Names}}' | grep -E 'mattermost' || true)
if [ -z "$RUNNING" ]; then
    warn "Containers may not have started. Check: docker logs mattermost"
else
    info "Containers running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for Mattermost to be ready on port 8065 (may take a few minutes)..."
HEALTH_OK=0
for i in $(seq 1 24); do
    if curl -sf --max-time 5 http://127.0.0.1:8065/api/v4/system/ping &>/dev/null; then
        info "Port 8065 is responding — Mattermost is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/24 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 8065 2>/dev/null; then
        warn "Port 8065 is open but API did not respond. Still initializing."
        warn "Check logs: docker logs mattermost"
    else
        warn "Port 8065 is NOT responding after 120s."
        warn "Check logs: docker logs mattermost"
        docker logs --tail 20 mattermost 2>&1 || true
    fi
fi

section "Step 10: Opening Firewall Port 8065"
if command -v ufw &> /dev/null; then
    ufw allow 8065/tcp
    info "UFW: port 8065/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Mattermost in your browser:              ║"
echo "  ║      👉  http://$SERVER_IP:8065"
echo "  ║                                                      ║"
echo "  ║  🔑  Create your admin account on first visit.     ║"
echo "  ║                                                      ║"
echo "  ║  📱  Desktop & Mobile apps available at:           ║"
echo "  ║      https://mattermost.com/download/              ║"
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
