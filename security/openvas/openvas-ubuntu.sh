#!/bin/bash
#
# ============================================================
#   OpenVAS / Greenbone Auto-Installer
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
echo "  ║     OpenVAS / Greenbone Auto-Installer           ║"
echo "  ║     Made by: Mohammed Ali Elshikh               ║"
echo "  ║     prismatechwork.com                          ║"
echo "  ║                                                  ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️         ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║                                                      ║"
echo "  ║  ⚠️   DEMO / TESTING USE ONLY                        ║"
echo "  ║                                                      ║"
echo "  ║  ⏳  WARNING: First startup takes 15-30 minutes     ║"
echo "  ║     for NVT feed synchronization.                   ║"
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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^openvas$' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing container: openvas"
    docker rm -f openvas 2>/dev/null || true
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
OV_DIR="/root/docker/openvas"
if [ -d "$OV_DIR" ]; then
    warn "Removing old directory $OV_DIR..."
    rm -rf "$OV_DIR"
fi
mkdir -p "$OV_DIR/data"
cd "$OV_DIR" || error "Cannot navigate to $OV_DIR"
info "Directory ready: $OV_DIR"

section "Step 6: Generating Credentials & docker-compose.yml"
ADMIN_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
info "Admin User     : admin"
info "Admin Password : $ADMIN_PASS"
warn "First startup takes 15-30 minutes for NVT feed sync."

cat > "$OV_DIR/docker-compose.yml" <<EOF
services:
  openvas:
    image: immauss/openvas:latest
    container_name: openvas
    restart: unless-stopped
    ports:
      - "9392:9392"
    environment:
      USERNAME: admin
      PASSWORD: $ADMIN_PASS
      DB_PASSWORD: $DB_PASS
    volumes:
      - ./data:/data
EOF
info "docker-compose.yml created."

section "Step 7: Starting OpenVAS / Greenbone"
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
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^openvas$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs openvas"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
warn "OpenVAS requires 15-30 minutes for NVT feed sync. Checking every 30s (36 attempts max)..."
HEALTH_OK=0
for i in $(seq 1 36); do
    if curl -sk --max-time 5 https://127.0.0.1:9392 &>/dev/null; then
        info "Port 9392 is responding — OpenVAS is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/36 — waiting 30s (feed sync in progress)..."
    sleep 30
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    warn "OpenVAS may still be syncing feeds. Check: docker logs openvas"
    warn "Try accessing https://<server-ip>:9392 in 10-20 more minutes."
fi

section "Step 10: Opening Firewall Port 9392"
if command -v ufw &> /dev/null; then
    ufw allow 9392/tcp
    info "UFW: port 9392/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open OpenVAS in your browser (accept SSL):   ║"
echo "  ║      👉  https://$SERVER_IP:9392"
echo "  ║                                                      ║"
echo "  ║  🔑  Login Credentials (save these!):              ║"
echo "  ║      Username : admin"
echo "  ║      Password : $ADMIN_PASS"
echo "  ║                                                      ║"
echo "  ║  ⏳  If not ready, wait 15-30 min for NVT sync.    ║"
echo "  ║      Monitor: docker logs openvas                   ║"
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
