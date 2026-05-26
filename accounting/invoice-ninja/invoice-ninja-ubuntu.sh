#!/bin/bash
#
# ============================================================
#   Invoice Ninja Auto-Installer
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
echo "  ║         Invoice Ninja Auto-Installer             ║"
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
for C in invoiceninja invoiceninja-db; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${C}$" || true)
    if [ -n "$EXISTING" ]; then
        warn "Removing existing container: $C"
        docker rm -f "$C" 2>/dev/null || true
    fi
done
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
IN_DIR="/root/docker/invoice-ninja"
if [ -d "$IN_DIR" ]; then
    warn "Removing old directory $IN_DIR..."
    rm -rf "$IN_DIR"
fi
mkdir -p "$IN_DIR/storage" "$IN_DIR/public"
cd "$IN_DIR" || error "Cannot navigate to $IN_DIR"
info "Directory ready: $IN_DIR"

section "Step 6: Generating Credentials & Writing docker-compose.yml"
apt-get install -y openssl &>/dev/null || true
DB_ROOT=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
ADMIN_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
APP_KEY="base64:$(openssl rand -base64 32)"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
info "Admin Email    : admin@example.com"
info "Admin Password : $ADMIN_PASS"

cat > "$IN_DIR/docker-compose.yml" <<EOF
services:
  invoiceninja-db:
    image: mariadb:10.6
    container_name: invoiceninja-db
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: $DB_ROOT
      MYSQL_DATABASE: invoiceninja
      MYSQL_USER: invoiceninja
      MYSQL_PASSWORD: $DB_PASS
    volumes:
      - ./db:/var/lib/mysql

  invoiceninja:
    image: invoiceninja/invoiceninja:5
    container_name: invoiceninja
    restart: unless-stopped
    depends_on:
      - invoiceninja-db
    ports:
      - "8128:80"
    environment:
      APP_URL: http://$SERVER_IP:8128
      APP_KEY: $APP_KEY
      APP_DEBUG: "false"
      DB_HOST: invoiceninja-db
      DB_DATABASE: invoiceninja
      DB_USERNAME: invoiceninja
      DB_PASSWORD: $DB_PASS
      MAIL_MAILER: log
      IN_USER_EMAIL: admin@example.com
      IN_PASSWORD: $ADMIN_PASS
    volumes:
      - ./storage:/var/www/app/storage
      - ./public:/var/www/app/public/storage
EOF
info "docker-compose.yml created."

section "Step 7: Starting Invoice Ninja"
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
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^invoiceninja$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs invoiceninja"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for Invoice Ninja to be ready on port 8128..."
HEALTH_OK=0
for i in $(seq 1 18); do
    if curl -sf --max-time 5 http://127.0.0.1:8128 &>/dev/null; then
        info "Port 8128 is responding — Invoice Ninja is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/18 — waiting 10s..."
    sleep 10
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    warn "Invoice Ninja may still be starting. Check: docker logs invoiceninja"
fi

section "Step 10: Opening Firewall Port 8128"
if command -v ufw &> /dev/null; then
    ufw allow 8128/tcp
    info "UFW: port 8128/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Invoice Ninja URL:                            ║"
echo "  ║      http://$SERVER_IP:8128"
echo "  ║                                                      ║"
echo "  ║  🔑  Login Credentials (save these!):              ║"
echo "  ║      Email    : admin@example.com"
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

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║                                                      ║"
echo "  ║  ☕  Support This Script                             ║"
echo "  ║                                                      ║"
echo "  ║  If this script saved you time, consider sending a  ║"
echo "  ║  small tip in USDT. It keeps the content free and   ║"
echo "  ║  helps publish more guides.                         ║"
echo "  ║                                                      ║"
echo "  ║  USDT · TRC-20:                                     ║"
echo "  ║  TCSZTkXvhibdrFre5sdTsFLRQ6d6yQkd2i               ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  TRC-20 network only. Do not send on ERC-20.   ║"
echo "  ║      Funds sent on other networks cannot be         ║"
echo "  ║      recovered.                                     ║"
echo "  ║                                                      ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
