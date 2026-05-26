#!/bin/bash
#
# ============================================================
#   Firefly III Auto-Installer
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
echo "  ║         Firefly III Auto-Installer               ║"
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
for cname in firefly firefly-db; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    if [ -n "$EXISTING" ]; then
        warn "Removing existing container: $cname"
        docker rm -f "$cname" 2>/dev/null || true
    fi
done
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
FF_DIR="/root/docker/firefly-iii"
if [ -d "$FF_DIR" ]; then
    warn "Removing old directory $FF_DIR..."
    rm -rf "$FF_DIR"
fi
mkdir -p "$FF_DIR/upload"
cd "$FF_DIR" || error "Cannot navigate to $FF_DIR"
info "Directory ready: $FF_DIR"

section "Step 6: Generating Credentials & docker-compose.yml"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
ROOT_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
apt-get install -y openssl &>/dev/null || true
APP_KEY_RAW=$(openssl rand -base64 32)
APP_KEY="base64:$APP_KEY_RAW"
info "Register your account on first visit at http://$SERVER_IP:8095"

cat > "$FF_DIR/docker-compose.yml" <<EOF
services:
  firefly-db:
    image: mariadb:10.11
    container_name: firefly-db
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: $ROOT_PASS
      MYSQL_DATABASE: firefly
      MYSQL_USER: firefly
      MYSQL_PASSWORD: $DB_PASS
    volumes:
      - ./mysql:/var/lib/mysql

  firefly:
    image: fireflyiii/core:latest
    container_name: firefly
    restart: unless-stopped
    ports:
      - "8095:8080"
    environment:
      APP_ENV: local
      APP_KEY: $APP_KEY
      DB_CONNECTION: mysql
      DB_HOST: firefly-db
      DB_PORT: 3306
      DB_DATABASE: firefly
      DB_USERNAME: firefly
      DB_PASSWORD: $DB_PASS
      APP_URL: http://$SERVER_IP:8095
      TRUSTED_PROXIES: "**"
      MAIL_MAILER: log
    volumes:
      - ./upload:/var/www/html/storage/upload
    depends_on:
      - firefly-db
EOF
info "docker-compose.yml created."

section "Step 7: Starting Firefly III"
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
sleep 15
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^firefly$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs firefly"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for Firefly III to be ready on port 8095 (may take ~2 minutes)..."
HEALTH_OK=0
for i in $(seq 1 18); do
    if curl -s --max-time 5 http://127.0.0.1:8095 &>/dev/null; then
        info "Port 8095 is responding — Firefly III is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/18 — waiting 10s..."
    sleep 10
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    warn "Firefly III may still be initializing. Check: docker logs firefly"
fi

section "Step 10: Opening Firewall Port 8095"
if command -v ufw &> /dev/null; then
    ufw allow 8095/tcp
    info "UFW: port 8095/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Firefly III in your browser:           ║"
echo "  ║      👉  http://$SERVER_IP:8095"
echo "  ║                                                      ║"
echo "  ║  🔑  Register your account on first visit.         ║"
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
