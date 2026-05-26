#!/bin/bash
#
# ============================================================
#   Zulip Auto-Installer
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
echo "  ║           Zulip Auto-Installer                   ║"
echo "  ║           Made by: Mohammed Ali Elshikh         ║"
echo "  ║           prismatechwork.com                    ║"
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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^zulip$' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing Zulip containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
ZULIP_DIR="/root/docker/zulip"
if [ -d "$ZULIP_DIR" ]; then
    warn "Removing old directory $ZULIP_DIR..."
    rm -rf "$ZULIP_DIR"
fi
mkdir -p "$ZULIP_DIR/data"
cd "$ZULIP_DIR" || error "Cannot navigate to $ZULIP_DIR"
info "Directory ready: $ZULIP_DIR"

section "Step 6: Generating Credentials & docker-compose.yml"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
RABBIT_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
SECRET=$(tr -dc 'a-f0-9' < /dev/urandom | head -c 64)
DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
ADMIN_PASS=$(tr -dc 'A-Za-z0-9!@#' < /dev/urandom | head -c 20)
ADMIN_EMAIL="admin@${SERVER_IP}.local"
info "Admin Email    : $ADMIN_EMAIL"
info "Admin Password : $ADMIN_PASS"

cat > "$ZULIP_DIR/docker-compose.yml" <<EOF
services:
  zulip:
    image: zulip/docker-zulip:latest
    container_name: zulip
    restart: unless-stopped
    ports:
      - "8585:80"
    environment:
      DB_HOST: 127.0.0.1
      DB_HOST_PORT: 5432
      DB_USER: zulip
      SETTING_MEMCACHED_LOCATION: 127.0.0.1:11211
      SETTING_RABBITMQ_HOST: 127.0.0.1
      SETTING_REDIS_HOST: 127.0.0.1
      SECRETS_rabbitmq_password: $RABBIT_PASS
      SECRETS_secret_key: $SECRET
      SECRETS_email_password: ""
      SECRETS_auth_ldap_bind_password: ""
      SECRETS_postgres_password: $DB_PASS
      SETTING_EXTERNAL_HOST: $SERVER_IP
      SETTING_ZULIP_ADMINISTRATOR: $ADMIN_EMAIL
      ZULIP_USER_EMAIL: $ADMIN_EMAIL
      ZULIP_USER_DOMAIN: ${SERVER_IP}.local
      ZULIP_USER_FULL_NAME: Admin
      ZULIP_USER_PASS: $ADMIN_PASS
      DISABLE_HTTPS: "true"
    volumes:
      - ./data:/data
EOF
info "docker-compose.yml created."

section "Step 7: Starting Zulip"
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
sleep 10
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^zulip$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs zulip"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for Zulip to be ready on port 8585 (may take 3-5 minutes)..."
HEALTH_OK=0
for i in $(seq 1 24); do
    if curl -sf --max-time 5 http://127.0.0.1:8585 &>/dev/null; then
        info "Port 8585 is responding — Zulip is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/24 — waiting 15s..."
    sleep 15
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 8585 2>/dev/null; then
        warn "Port 8585 is open but Zulip may still be initializing."
        warn "Check logs: docker logs zulip"
    else
        warn "Port 8585 is NOT responding."
        docker logs --tail 20 zulip 2>&1 || true
    fi
fi

section "Step 10: Opening Firewall Port 8585"
if command -v ufw &> /dev/null; then
    ufw allow 8585/tcp
    info "UFW: port 8585/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Zulip in your browser:                  ║"
echo "  ║      👉  http://$SERVER_IP:8585"
echo "  ║                                                      ║"
echo "  ║  🔑  Login Credentials (save these!):              ║"
echo "  ║      Email    : $ADMIN_EMAIL"
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
