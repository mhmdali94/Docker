#!/bin/bash
#
# ============================================================
#   OpenMRS Auto-Installer
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
echo "  ║         OpenMRS Auto-Installer                   ║"
echo "  ║         Made by: Mohammed Ali Elshikh           ║"
echo "  ║         prismatechwork.com                      ║"
echo "  ║                                                  ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️         ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║                                                      ║"
echo "  ║  ⚠️   DEMO / TESTING USE ONLY                        ║"
echo "  ║                                                      ║"
echo "  ║  ⏳  First startup takes 5-10 minutes while         ║"
echo "  ║     OpenMRS initializes the database schema.        ║"
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
for C in openmrs openmrs-db; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${C}$" || true)
    if [ -n "$EXISTING" ]; then
        warn "Removing existing container: $C"
        docker rm -f "$C" 2>/dev/null || true
    fi
done
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
OM_DIR="/root/docker/openmrs"
if [ -d "$OM_DIR" ]; then
    warn "Removing old directory $OM_DIR..."
    rm -rf "$OM_DIR"
fi
mkdir -p "$OM_DIR/data"
cd "$OM_DIR" || error "Cannot navigate to $OM_DIR"
info "Directory ready: $OM_DIR"

section "Step 6: Writing docker-compose.yml"
DB_ROOT=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
warn "Default login after initialization: admin / Admin123 — change immediately."

cat > "$OM_DIR/docker-compose.yml" <<EOF
services:
  openmrs-db:
    image: mysql:8
    container_name: openmrs-db
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: $DB_ROOT
      MYSQL_DATABASE: openmrs
      MYSQL_USER: openmrs
      MYSQL_PASSWORD: $DB_PASS
    volumes:
      - ./db:/var/lib/mysql
    command: --character-set-server=utf8 --collation-server=utf8_general_ci

  openmrs:
    image: openmrs/openmrs-reference-application:latest
    container_name: openmrs
    restart: unless-stopped
    depends_on:
      - openmrs-db
    ports:
      - "8122:8080"
    environment:
      DB_DATABASE: openmrs
      DB_HOST: openmrs-db
      DB_USERNAME: openmrs
      DB_PASSWORD: $DB_PASS
      DB_CREATE_TABLES: "true"
      DB_AUTO_UPDATE: "true"
      MODULE_WEB_ADMIN: "true"
    volumes:
      - ./data:/usr/local/tomcat/.OpenMRS
EOF
info "docker-compose.yml created."

section "Step 7: Starting OpenMRS"
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    if docker compose version &> /dev/null; then
        docker compose up -d && break
    else
        docker-compose up -d && break
    fi
    warn "Docker pull failed on attempt $attempt/$MAX_RETRIES (registry may be temporarily unavailable)."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed to start after $MAX_RETRIES attempts. Run manually: cd $PWD && docker compose up -d"
done

section "Step 8: Verifying Container"
sleep 20
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^openmrs$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs openmrs"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
warn "OpenMRS initializes the database schema on first run — this takes 5-10 minutes."
HEALTH_OK=0
for i in $(seq 1 24); do
    if curl -s --max-time 5 http://127.0.0.1:8122/openmrs/ &>/dev/null; then
        info "Port 8122 is responding — OpenMRS is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/24 — waiting 30s (DB init in progress)..."
    sleep 30
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    warn "OpenMRS may still be initializing. Check: docker logs openmrs"
    warn "Try accessing http://<server-ip>:8122/openmrs in 5-10 more minutes."
fi

section "Step 10: Opening Firewall Port 8122"
if command -v ufw &> /dev/null; then
    ufw allow 8122/tcp
    info "UFW: port 8122/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  OpenMRS URL:                                  ║"
echo "  ║      http://$SERVER_IP:8122/openmrs"
echo "  ║                                                      ║"
echo "  ║  🔑  Default Login (change immediately!):          ║"
echo "  ║      Username : admin"
echo "  ║      Password : Admin123"
echo "  ║                                                      ║"
echo "  ║  ⏳  If not ready, wait 5-10 min for DB init.      ║"
echo "  ║      Monitor: docker logs openmrs                   ║"
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
