#!/bin/bash
#
# ============================================================
#   Umami Web Analytics Auto-Installer
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
echo "  ║       Umami Web Analytics Auto-Installer         ║"
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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E 'umami' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing Umami containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
UMAMI_DIR="/root/docker/umami"
if [ -d "$UMAMI_DIR" ]; then
    warn "Removing old directory $UMAMI_DIR..."
    rm -rf "$UMAMI_DIR"
fi
mkdir -p "$UMAMI_DIR"
cd "$UMAMI_DIR" || error "Cannot navigate to $UMAMI_DIR"
info "Directory ready: $UMAMI_DIR"

section "Step 6: Generating Credentials & docker-compose.yml"
UMAMI_DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 24)
UMAMI_APP_SECRET=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)
info "Default credentials: admin / umami  (change after first login)"

cat > "$UMAMI_DIR/docker-compose.yml" <<EOF
services:
  umami-db:
    image: postgres:15-alpine
    container_name: umami-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: umami
      POSTGRES_USER: umami
      POSTGRES_PASSWORD: $UMAMI_DB_PASS
    volumes:
      - ./pgdata:/var/lib/postgresql/data
    networks:
      - umami-net

  umami:
    image: ghcr.io/umami-software/umami:postgresql-latest
    container_name: umami
    restart: unless-stopped
    depends_on:
      - umami-db
    ports:
      - "3002:3000"
    environment:
      DATABASE_URL: postgresql://umami:$UMAMI_DB_PASS@umami-db:5432/umami
      DATABASE_TYPE: postgresql
      APP_SECRET: $UMAMI_APP_SECRET
    networks:
      - umami-net

networks:
  umami-net:
    driver: bridge
EOF
info "docker-compose.yml created."

section "Step 7: Starting Umami"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 8: Verifying Containers"
sleep 10
RUNNING=$(docker ps --format '{{.Names}}' | grep -E 'umami' || true)
if [ -z "$RUNNING" ]; then
    warn "Containers may not have started. Check: docker logs umami"
else
    info "Containers running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for Umami to be ready on port 3002 (may take a minute)..."
HEALTH_OK=0
for i in $(seq 1 24); do
    if curl -sf --max-time 5 http://127.0.0.1:3002/api/heartbeat &>/dev/null; then
        info "Port 3002 is responding — Umami is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/24 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 3002 2>/dev/null; then
        warn "Port 3002 is open but API did not respond. Still initializing."
        warn "Check logs: docker logs umami"
    else
        warn "Port 3002 is NOT responding after 120s."
        warn "Check logs: docker logs umami"
        docker logs --tail 20 umami 2>&1 || true
    fi
fi

section "Step 10: Opening Firewall Port 3002"
if command -v ufw &> /dev/null; then
    ufw allow 3002/tcp
    info "UFW: port 3002/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Umami in your browser:                   ║"
echo "  ║      👉  http://$SERVER_IP:3002"
echo "  ║                                                      ║"
echo "  ║  🔑  Default Credentials (change immediately!):    ║"
echo "  ║      Username : admin"
echo "  ║      Password : umami"
echo "  ║                                                      ║"
echo "  ║  📊  Add your website in Settings → Websites        ║"
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
