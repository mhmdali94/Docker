#!/bin/bash
#
# ============================================================
#   Outline Wiki Auto-Installer
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
echo "  ║         Outline Wiki Auto-Installer              ║"
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
for cname in outline outline-db outline-redis; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    if [ -n "$EXISTING" ]; then
        warn "Removing existing container: $cname"
        docker rm -f "$cname" 2>/dev/null || true
    fi
done
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
OUTLINE_DIR="/root/docker/outline"
if [ -d "$OUTLINE_DIR" ]; then
    warn "Removing old directory $OUTLINE_DIR..."
    rm -rf "$OUTLINE_DIR"
fi
mkdir -p "$OUTLINE_DIR"
cd "$OUTLINE_DIR" || error "Cannot navigate to $OUTLINE_DIR"
info "Directory ready: $OUTLINE_DIR"

section "Step 6: Generating Credentials & docker-compose.yml"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
SECRET=$(tr -dc 'a-f0-9' < /dev/urandom | head -c 64)
UTILS_SECRET=$(tr -dc 'a-f0-9' < /dev/urandom | head -c 64)
info "URL: http://$SERVER_IP:3003"
warn "NOTE: Outline requires OAuth (Google/Slack/GitHub) or SMTP for login."
warn "      Set SLACK_KEY/SLACK_SECRET or configure SMTP in the compose file."

cat > "$OUTLINE_DIR/docker-compose.yml" <<EOF
services:
  outline-db:
    image: postgres:15
    container_name: outline-db
    restart: unless-stopped
    environment:
      POSTGRES_USER: outline
      POSTGRES_PASSWORD: $DB_PASS
      POSTGRES_DB: outline
    volumes:
      - ./postgres:/var/lib/postgresql/data

  outline-redis:
    image: redis:7
    container_name: outline-redis
    restart: unless-stopped
    volumes:
      - ./redis:/data

  outline:
    image: outlinewiki/outline:latest
    container_name: outline
    restart: unless-stopped
    ports:
      - "3003:3000"
    environment:
      SECRET_KEY: $SECRET
      UTILS_SECRET: $UTILS_SECRET
      DATABASE_URL: postgres://outline:$DB_PASS@outline-db:5432/outline
      REDIS_URL: redis://outline-redis:6379
      URL: http://$SERVER_IP:3003
      PORT: 3000
      FORCE_HTTPS: "false"
      PGSSLMODE: disable
      FILE_STORAGE: local
      FILE_STORAGE_LOCAL_ROOT_DIR: /var/lib/outline/data
      FILE_STORAGE_UPLOAD_MAX_SIZE: 26214400
    volumes:
      - ./data:/var/lib/outline/data
    depends_on:
      - outline-db
      - outline-redis
EOF
info "docker-compose.yml created."

section "Step 7: Starting Outline"
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
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^outline$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs outline"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for Outline to be ready on port 3003..."
HEALTH_OK=0
for i in $(seq 1 12); do
    if curl -s --max-time 5 http://127.0.0.1:3003 &>/dev/null; then
        info "Port 3003 is responding — Outline is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 10s..."
    sleep 10
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    warn "Outline may still be initializing. Check: docker logs outline"
fi

section "Step 10: Opening Firewall Port 3003"
if command -v ufw &> /dev/null; then
    ufw allow 3003/tcp
    info "UFW: port 3003/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Outline in your browser:               ║"
echo "  ║      👉  http://$SERVER_IP:3003"
echo "  ║                                                      ║"
echo "  ║  🔑  Login requires OAuth or SMTP configuration.   ║"
echo "  ║      Edit docker-compose.yml to add:               ║"
echo "  ║      SLACK_KEY / SLACK_SECRET  (easiest option)    ║"
echo "  ║      or SMTP_* variables for email login           ║"
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
