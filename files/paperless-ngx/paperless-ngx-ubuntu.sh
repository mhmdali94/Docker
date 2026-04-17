#!/bin/bash
#
# ============================================================
#   Paperless-NGX Document Management Auto-Installer
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
echo "  ║       Paperless-NGX Document Mgmt Installer      ║"
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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E 'paperless' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing Paperless-NGX containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
PL_DIR="/root/docker/paperless-ngx"
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
PL_ADMIN_PASS=$(tr -dc 'A-Za-z0-9!@#$%' < /dev/urandom | head -c 20)
info "Admin User     : admin"
info "Admin Password : $PL_ADMIN_PASS"

cat > "$PL_DIR/docker-compose.yml" <<EOF
services:
  paperless-broker:
    image: redis:7
    container_name: paperless-broker
    restart: unless-stopped
    networks:
      - paperless-net

  paperless-db:
    image: postgres:15
    container_name: paperless-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: paperless
      POSTGRES_USER: paperless
      POSTGRES_PASSWORD: $PL_DB_PASS
    volumes:
      - ./pgdata:/var/lib/postgresql/data
    networks:
      - paperless-net

  paperless:
    image: ghcr.io/paperless-ngx/paperless-ngx:latest
    container_name: paperless
    restart: unless-stopped
    depends_on:
      - paperless-db
      - paperless-broker
    ports:
      - "8010:8000"
    environment:
      PAPERLESS_REDIS: redis://paperless-broker:6379
      PAPERLESS_DBENGINE: postgresql
      PAPERLESS_DBHOST: paperless-db
      PAPERLESS_DBNAME: paperless
      PAPERLESS_DBUSER: paperless
      PAPERLESS_DBPASS: $PL_DB_PASS
      PAPERLESS_SECRET_KEY: $PL_SECRET
      PAPERLESS_ADMIN_USER: admin
      PAPERLESS_ADMIN_PASSWORD: $PL_ADMIN_PASS
      PAPERLESS_TIME_ZONE: UTC
      PAPERLESS_OCR_LANGUAGE: eng
    volumes:
      - ./data:/usr/src/paperless/data
      - ./media:/usr/src/paperless/media
      - ./export:/usr/src/paperless/export
      - ./consume:/usr/src/paperless/consume
    networks:
      - paperless-net

networks:
  paperless-net:
    driver: bridge
EOF
info "docker-compose.yml created."

section "Step 7: Starting Paperless-NGX"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 8: Verifying Containers"
sleep 8
RUNNING=$(docker ps --format '{{.Names}}' | grep -E 'paperless' || true)
if [ -z "$RUNNING" ]; then
    warn "Containers may not have started. Check: docker logs paperless"
else
    info "Containers running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for Paperless-NGX to be ready on port 8010..."
HEALTH_OK=0
for i in $(seq 1 24); do
    if curl -sf --max-time 5 http://127.0.0.1:8010 &>/dev/null; then
        info "Port 8010 is responding — Paperless-NGX is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/24 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 8010 2>/dev/null; then
        warn "Port 8010 is open but HTTP did not respond. Still initializing."
        warn "Check logs: docker logs paperless"
    else
        warn "Port 8010 is NOT responding after 120s."
        docker logs --tail 20 paperless 2>&1 || true
    fi
fi

section "Step 10: Opening Firewall Port 8010"
if command -v ufw &> /dev/null; then
    ufw allow 8010/tcp
    info "UFW: port 8010/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Paperless-NGX in your browser:           ║"
echo "  ║      👉  http://$SERVER_IP:8010"
echo "  ║                                                      ║"
echo "  ║  🔑  Login Credentials (save these!):              ║"
echo "  ║      Username : admin"
echo "  ║      Password : $PL_ADMIN_PASS"
echo "  ║                                                      ║"
echo "  ║  📄  Drop documents into consume folder:           ║"
echo "  ║      $PL_DIR/consume"
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
