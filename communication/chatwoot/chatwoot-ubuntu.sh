#!/bin/bash
#
# ============================================================
#   Chatwoot Auto-Installer
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
echo "  ║          Chatwoot Auto-Installer                 ║"
echo "  ║          Made by: Mohammed Ali Elshikh          ║"
echo "  ║          prismatechwork.com                     ║"
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
for cname in chatwoot-server chatwoot-sidekiq chatwoot-db chatwoot-redis; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    if [ -n "$EXISTING" ]; then
        warn "Removing existing container: $cname"
        docker rm -f "$cname" 2>/dev/null || true
    fi
done
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
CW_DIR="/root/docker/chatwoot"
if [ -d "$CW_DIR" ]; then
    warn "Removing old directory $CW_DIR..."
    rm -rf "$CW_DIR"
fi
mkdir -p "$CW_DIR/storage"
cd "$CW_DIR" || error "Cannot navigate to $CW_DIR"
info "Directory ready: $CW_DIR"

section "Step 6: Generating Credentials & docker-compose.yml"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
SECRET=$(tr -dc 'a-f0-9' < /dev/urandom | head -c 64)
info "Credentials generated."

cat > "$CW_DIR/docker-compose.yml" <<EOF
services:
  chatwoot-db:
    image: postgres:15
    container_name: chatwoot-db
    restart: unless-stopped
    environment:
      POSTGRES_USER: chatwoot
      POSTGRES_PASSWORD: $DB_PASS
      POSTGRES_DB: chatwoot_production
    volumes:
      - ./postgres:/var/lib/postgresql/data

  chatwoot-redis:
    image: redis:7
    container_name: chatwoot-redis
    restart: unless-stopped
    volumes:
      - ./redis:/data

  chatwoot-server:
    image: chatwoot/chatwoot:latest
    container_name: chatwoot-server
    restart: unless-stopped
    command: bundle exec rails s -p 3000 -b 0.0.0.0
    ports:
      - "3008:3000"
    environment:
      NODE_ENV: production
      RAILS_ENV: production
      SECRET_KEY_BASE: $SECRET
      FRONTEND_URL: http://$SERVER_IP:3008
      DEFAULT_LOCALE: en
      FORCE_SSL: "false"
      ENABLE_ACCOUNT_SIGNUP: "true"
      REDIS_URL: redis://chatwoot-redis:6379
      POSTGRES_HOST: chatwoot-db
      POSTGRES_PORT: 5432
      POSTGRES_USERNAME: chatwoot
      POSTGRES_PASSWORD: $DB_PASS
      POSTGRES_DATABASE: chatwoot_production
    volumes:
      - ./storage:/app/storage
    depends_on:
      - chatwoot-db
      - chatwoot-redis

  chatwoot-sidekiq:
    image: chatwoot/chatwoot:latest
    container_name: chatwoot-sidekiq
    restart: unless-stopped
    command: bundle exec sidekiq -C config/sidekiq.yml
    environment:
      NODE_ENV: production
      RAILS_ENV: production
      SECRET_KEY_BASE: $SECRET
      FRONTEND_URL: http://$SERVER_IP:3008
      REDIS_URL: redis://chatwoot-redis:6379
      POSTGRES_HOST: chatwoot-db
      POSTGRES_PORT: 5432
      POSTGRES_USERNAME: chatwoot
      POSTGRES_PASSWORD: $DB_PASS
      POSTGRES_DATABASE: chatwoot_production
    depends_on:
      - chatwoot-db
      - chatwoot-redis
      - chatwoot-server
EOF
info "docker-compose.yml created."

section "Step 6b: Preparing Chatwoot Database"
info "Starting database containers..."
if docker compose version &> /dev/null; then
    docker compose up -d chatwoot-db chatwoot-redis
else
    docker-compose up -d chatwoot-db chatwoot-redis
fi
sleep 10
info "Running Chatwoot DB preparation..."
if docker compose version &> /dev/null; then
    docker compose run --rm chatwoot-server bundle exec rails db:chatwoot_prepare || warn "DB prep returned non-zero — continuing."
else
    docker-compose run --rm chatwoot-server bundle exec rails db:chatwoot_prepare || warn "DB prep returned non-zero — continuing."
fi

section "Step 7: Starting Chatwoot"
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
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^chatwoot-server$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs chatwoot-server"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for Chatwoot to be ready on port 3008..."
HEALTH_OK=0
for i in $(seq 1 18); do
    if curl -s --max-time 5 http://127.0.0.1:3008 &>/dev/null; then
        info "Port 3008 is responding — Chatwoot is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/18 — waiting 10s..."
    sleep 10
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 3008 2>/dev/null; then
        warn "Port 3008 is open but Chatwoot may still be initializing."
        warn "Check logs: docker logs chatwoot-server"
    else
        warn "Port 3008 is NOT responding."
        docker logs --tail 20 chatwoot-server 2>&1 || true
    fi
fi

section "Step 10: Opening Firewall Port 3008"
if command -v ufw &> /dev/null; then
    ufw allow 3008/tcp
    info "UFW: port 3008/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Chatwoot in your browser:               ║"
echo "  ║      👉  http://$SERVER_IP:3008"
echo "  ║                                                      ║"
echo "  ║  🔑  Register admin at: /auth/sign_up              ║"
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
