#!/bin/bash
#
# ============================================================
#   Typebot Auto-Installer
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
echo "  ║         Typebot Auto-Installer                   ║"
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
for cname in typebot-builder typebot-viewer typebot-db; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    if [ -n "$EXISTING" ]; then
        warn "Removing existing container: $cname"
        docker rm -f "$cname" 2>/dev/null || true
    fi
done
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
TB_DIR="/root/docker/typebot"
if [ -d "$TB_DIR" ]; then
    warn "Removing old directory $TB_DIR..."
    rm -rf "$TB_DIR"
fi
mkdir -p "$TB_DIR"
cd "$TB_DIR" || error "Cannot navigate to $TB_DIR"
info "Directory ready: $TB_DIR"

section "Step 6: Generating Credentials & docker-compose.yml"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
NEXTAUTH_SECRET=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)
ENCRYPTION_SECRET=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 24)
info "Builder URL : http://$SERVER_IP:3310"
info "Viewer URL  : http://$SERVER_IP:3311"

cat > "$TB_DIR/docker-compose.yml" <<EOF
services:
  typebot-db:
    image: postgres:15
    container_name: typebot-db
    restart: unless-stopped
    environment:
      POSTGRES_USER: typebot
      POSTGRES_PASSWORD: $DB_PASS
      POSTGRES_DB: typebot
    volumes:
      - ./postgres:/var/lib/postgresql/data

  typebot-builder:
    image: baptistearno/typebot-builder:latest
    container_name: typebot-builder
    restart: unless-stopped
    ports:
      - "3310:3000"
    environment:
      DATABASE_URL: postgresql://typebot:$DB_PASS@typebot-db:5432/typebot
      NEXTAUTH_URL: http://$SERVER_IP:3310
      NEXTAUTH_SECRET: $NEXTAUTH_SECRET
      ENCRYPTION_SECRET: $ENCRYPTION_SECRET
      NEXT_PUBLIC_VIEWER_URL: http://$SERVER_IP:3311
      ADMIN_EMAIL: admin@typebot.local
      DISABLE_SIGNUP: "false"
    depends_on:
      - typebot-db

  typebot-viewer:
    image: baptistearno/typebot-viewer:latest
    container_name: typebot-viewer
    restart: unless-stopped
    ports:
      - "3311:3000"
    environment:
      DATABASE_URL: postgresql://typebot:$DB_PASS@typebot-db:5432/typebot
      NEXTAUTH_URL: http://$SERVER_IP:3310
      NEXTAUTH_SECRET: $NEXTAUTH_SECRET
      ENCRYPTION_SECRET: $ENCRYPTION_SECRET
      NEXT_PUBLIC_VIEWER_URL: http://$SERVER_IP:3311
    depends_on:
      - typebot-db
EOF
info "docker-compose.yml created."

section "Step 7: Starting Typebot"
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

section "Step 8: Verifying Containers"
sleep 15
for cname in typebot-builder typebot-viewer; do
    RUNNING=$(docker ps --format '{{.Names}}' | grep -E "^${cname}$" || true)
    if [ -z "$RUNNING" ]; then
        warn "Container '$cname' may not have started. Check: docker logs $cname"
    else
        info "Container running: $cname"
    fi
done

section "Step 9: Health Check"
info "Waiting for Typebot Builder to be ready on port 3310..."
HEALTH_OK=0
for i in $(seq 1 18); do
    if curl -sf --max-time 5 http://127.0.0.1:3310 &>/dev/null; then
        info "Port 3310 is responding — Typebot Builder is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/18 — waiting 10s..."
    sleep 10
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    warn "Typebot may still be initializing. Check: docker logs typebot-builder"
fi

section "Step 10: Opening Firewall Ports 3310 & 3311"
if command -v ufw &> /dev/null; then
    ufw allow 3310/tcp
    ufw allow 3311/tcp
    info "UFW: ports 3310 and 3311/tcp opened."
else
    warn "UFW not found — skipping firewall rules."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Typebot Builder (design bots):               ║"
echo "  ║      👉  http://$SERVER_IP:3310"
echo "  ║                                                      ║"
echo "  ║  🌐  Typebot Viewer (serve bots):                 ║"
echo "  ║      👉  http://$SERVER_IP:3311"
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
