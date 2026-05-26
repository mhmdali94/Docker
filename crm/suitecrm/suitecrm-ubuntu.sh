#!/bin/bash
#
# ============================================================
#   SuiteCRM Auto-Installer
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
echo "  ║         SuiteCRM Auto-Installer                  ║"
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
for C in suitecrm suitecrm-db; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${C}$" || true)
    if [ -n "$EXISTING" ]; then
        warn "Removing existing container: $C"
        docker rm -f "$C" 2>/dev/null || true
    fi
done
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
SC_DIR="/root/docker/suitecrm"
if [ -d "$SC_DIR" ]; then
    warn "Removing old directory $SC_DIR..."
    rm -rf "$SC_DIR"
fi
mkdir -p "$SC_DIR/data"
cd "$SC_DIR" || error "Cannot navigate to $SC_DIR"
info "Directory ready: $SC_DIR"

section "Step 6: Generating Credentials & Writing docker-compose.yml"
DB_ROOT=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
ADMIN_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
info "Admin User     : admin"
info "Admin Password : $ADMIN_PASS"

cat > "$SC_DIR/docker-compose.yml" <<EOF
services:
  suitecrm-db:
    image: bitnami/mariadb:10.6
    container_name: suitecrm-db
    restart: unless-stopped
    environment:
      MARIADB_ROOT_PASSWORD: $DB_ROOT
      MARIADB_DATABASE: bitnami_suitecrm
      MARIADB_USER: bn_suitecrm
      MARIADB_PASSWORD: $DB_PASS
    volumes:
      - ./db:/bitnami/mariadb

  suitecrm:
    image: bitnami/suitecrm:latest
    container_name: suitecrm
    restart: unless-stopped
    depends_on:
      - suitecrm-db
    ports:
      - "8129:8080"
    environment:
      SUITECRM_DATABASE_HOST: suitecrm-db
      SUITECRM_DATABASE_PORT_NUMBER: 3306
      SUITECRM_DATABASE_NAME: bitnami_suitecrm
      SUITECRM_DATABASE_USER: bn_suitecrm
      SUITECRM_DATABASE_PASSWORD: $DB_PASS
      SUITECRM_USERNAME: admin
      SUITECRM_PASSWORD: $ADMIN_PASS
      SUITECRM_EMAIL: admin@example.com
      SUITECRM_HOST: $SERVER_IP
    volumes:
      - ./data:/bitnami/suitecrm
EOF
info "docker-compose.yml created."

section "Step 7: Starting SuiteCRM"
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
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^suitecrm$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs suitecrm"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for SuiteCRM to be ready on port 8129 (first setup takes 3-5 min)..."
HEALTH_OK=0
for i in $(seq 1 18); do
    if curl -sf --max-time 5 http://127.0.0.1:8129 &>/dev/null; then
        info "Port 8129 is responding — SuiteCRM is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/18 — waiting 20s..."
    sleep 20
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    warn "SuiteCRM may still be initializing. Check: docker logs suitecrm"
fi

section "Step 10: Opening Firewall Port 8129"
if command -v ufw &> /dev/null; then
    ufw allow 8129/tcp
    info "UFW: port 8129/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  SuiteCRM URL:                                 ║"
echo "  ║      http://$SERVER_IP:8129"
echo "  ║                                                      ║"
echo "  ║  🔑  Login Credentials (save these!):              ║"
echo "  ║      Username : admin"
echo "  ║      Password : $ADMIN_PASS"
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
