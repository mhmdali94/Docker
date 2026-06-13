#!/bin/bash
#
# ============================================================
#   OpenSourcePOS Auto-Installer
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
echo "  ║         OpenSourcePOS Auto-Installer             ║"
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
echo "  ║  ⏳  First startup takes 2-3 minutes.              ║"
echo "  ║     A database migration page will appear on first ║"
echo "  ║     visit — enter admin/pointofsale to migrate.    ║"
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
for C in opensourcepos opensourcepos-db; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${C}$" || true)
    if [ -n "$EXISTING" ]; then
        warn "Removing existing container: $C"
        docker rm -f "$C" 2>/dev/null || true
    fi
done
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
OSPOS_DIR="/root/docker/opensourcepos"
if [ -d "$OSPOS_DIR" ]; then
    warn "Removing old directory $OSPOS_DIR..."
    rm -rf "$OSPOS_DIR"
fi
mkdir -p "$OSPOS_DIR/db" "$OSPOS_DIR/public"
cd "$OSPOS_DIR" || error "Cannot navigate to $OSPOS_DIR"
info "Directory ready: $OSPOS_DIR"

section "Step 6: Generating Credentials & Writing docker-compose.yml"
DB_ROOT=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
info "Database Name  : ospos"
info "Database User  : admin"
info "Database Pass  : pointofsale"
info "Default Login  : username=admin / password=pointofsale"

cat > "$OSPOS_DIR/.env" << 'ENVEOF'
CI_ENVIRONMENT = production
app.allowedHostnames = 'localhost,SERVER_IP_PLACEHOLDER:8130'
database.default.hostname = opensourcepos-db
database.default.database = ospos
database.default.username = admin
database.default.password = pointofsale
database.default.DBDriver = 'MySQLi'
database.default.DBPrefix = 'ospos_'
encryption.key = 'ENC_KEY_PLACEHOLDER'
logger.threshold = 0
app.db_log_enabled = false
honeypot.hidden = true
honeypot.label = 'Fill This Field'
honeypot.name = 'honeypot'
honeypot.template = '<label>{label}</label><input type="text" name="{name} value="">'
honeypot.container = '<div style="display:none">{template}</div>'
ENVEOF
sed -i "s/SERVER_IP_PLACEHOLDER/${SERVER_IP}/g" "$OSPOS_DIR/.env"
ENC_KEY=$(openssl rand -hex 32)
sed -i "s/ENC_KEY_PLACEHOLDER/${ENC_KEY}/g" "$OSPOS_DIR/.env"
info ".env file created."

cat > "$OSPOS_DIR/docker-compose.yml" <<EOF
services:
  opensourcepos-db:
    image: mariadb:10.5
    container_name: opensourcepos-db
    restart: unless-stopped
    networks:
      - app_net
    environment:
      MYSQL_ROOT_PASSWORD: $DB_ROOT
      MYSQL_DATABASE: ospos
      MYSQL_USER: admin
      MYSQL_PASSWORD: pointofsale
    volumes:
      - db:/var/lib/mysql

  opensourcepos:
    image: jekkos/opensourcepos:master
    container_name: opensourcepos
    restart: unless-stopped
    depends_on:
      - opensourcepos-db
    ports:
      - "8130:80"
    networks:
      - app_net
    environment:
      PHP_TIMEZONE: UTC
      MYSQL_HOST_NAME: opensourcepos-db
      MYSQL_USERNAME: admin
      MYSQL_PASSWORD: pointofsale
      MYSQL_DB_NAME: ospos
    volumes:
      - uploads:/app/public/uploads
      - logs:/app/writable/logs
      - ./.env:/app/.env

volumes:
  uploads:
    driver: local
  logs:
    driver: local
  db:
    driver: local

networks:
  app_net:
EOF
info "docker-compose.yml created."

section "Step 7: Starting OpenSourcePOS"
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
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^opensourcepos$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs opensourcepos"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for OpenSourcePOS to be ready on port 8130 (first setup takes 2-3 min)..."
HEALTH_OK=0
for i in $(seq 1 18); do
    if curl -s --max-time 5 http://127.0.0.1:8130 &>/dev/null; then
        info "Port 8130 is responding — OpenSourcePOS is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/18 — waiting 20s..."
    sleep 20
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    warn "OpenSourcePOS may still be initializing. Check: docker logs opensourcepos"
fi

section "Step 10: Opening Firewall Port 8130"
if command -v ufw &> /dev/null; then
    ufw allow 8130/tcp
    info "UFW: port 8130/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

section "Step 11: Database Migration Notice"
info "OpenSourcePOS requires a one-time database migration on first visit."
warn "After opening the URL below, a migration page will appear."
info "Enter the credentials below to authorize the migration, then click Migrate."

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  OpenSourcePOS URL:                            ║"
echo "  ║      http://$SERVER_IP:8130"
echo "  ║                                                      ║"
echo "  ║  🔑  Migration Credentials (enter on first visit): ║"
echo "  ║      Username : admin                               ║"
echo "  ║      Password : pointofsale                         ║"
echo "  ║                                                      ║"
echo "  ║  🗄️  Database Credentials:                         ║"
echo "  ║      Database : ospos"
echo "  ║      User     : admin"
echo "  ║      Password : pointofsale"
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
