#!/bin/bash
#
# ============================================================
#   Odoo 17 Auto-Installer
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
echo "  ║         Odoo 17 Auto-Installer                   ║"
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
for C in odoo17 odoo17-db; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${C}$" || true)
    if [ -n "$EXISTING" ]; then
        warn "Removing existing container: $C"
        docker rm -f "$C" 2>/dev/null || true
    fi
done
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
ODOO_DIR="/root/docker/odoo17"
if [ -d "$ODOO_DIR" ]; then
    warn "Removing old directory $ODOO_DIR..."
    rm -rf "$ODOO_DIR"
fi
mkdir -p "$ODOO_DIR/data" "$ODOO_DIR/addons"
chown -R 101:101 "$ODOO_DIR/data"
cd "$ODOO_DIR" || error "Cannot navigate to $ODOO_DIR"
info "Directory ready: $ODOO_DIR"

section "Step 6: Generating Credentials & Writing Config"
DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
MASTER_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
info "DB Password     : $DB_PASS"
info "Master Password : $MASTER_PASS"

cat > "$ODOO_DIR/odoo.conf" <<EOF
[options]
admin_passwd = $MASTER_PASS
db_host = odoo17-db
db_port = 5432
db_user = odoo
db_password = $DB_PASS
EOF

cat > "$ODOO_DIR/docker-compose.yml" <<EOF
services:
  odoo17-db:
    image: postgres:15
    container_name: odoo17-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: postgres
      POSTGRES_USER: odoo
      POSTGRES_PASSWORD: $DB_PASS
    volumes:
      - ./db:/var/lib/postgresql/data

  odoo17:
    image: odoo:17
    container_name: odoo17
    restart: unless-stopped
    depends_on:
      - odoo17-db
    ports:
      - "8017:8069"
    volumes:
      - ./data:/var/lib/odoo
      - ./addons:/mnt/extra-addons
      - ./odoo.conf:/etc/odoo/odoo.conf
EOF
info "docker-compose.yml created."

section "Step 7: Starting Odoo 17"
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
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^odoo17$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs odoo17"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for Odoo 17 to be ready on port 8017 (first pull may take time)..."
HEALTH_OK=0
for i in $(seq 1 18); do
    if curl -s --max-time 5 http://127.0.0.1:8017 &>/dev/null; then
        info "Port 8017 is responding — Odoo 17 is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/18 — waiting 10s..."
    sleep 10
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    warn "Odoo may still be loading. Check: docker logs odoo17"
fi

section "Step 10: Opening Firewall Port 8017"
if command -v ufw &> /dev/null; then
    ufw allow 8017/tcp
    info "UFW: port 8017/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Odoo 17 URL:                                  ║"
echo "  ║      http://$SERVER_IP:8017"
echo "  ║                                                      ║"
echo "  ║  🗄️  Database Manager:                             ║"
echo "  ║  http://$SERVER_IP:8017/web/database/manager"
echo "  ║                                                      ║"
echo "  ║  🔑  Master Password (save this!):                 ║"
echo "  ║      $MASTER_PASS"
echo "  ║                                                      ║"
echo "  ║  ℹ️  Create your first DB via the manager URL.      ║"
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
