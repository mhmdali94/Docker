#!/bin/bash
#
# ============================================================
#   FileBrowser Auto-Installer
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
echo "  ║       FileBrowser Auto-Installer                 ║"
echo "  ║       Made by: Mohammed Ali Elshikh             ║"
echo "  ║       prismatechwork.com                        ║"
echo "  ║                                                  ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️         ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║  ⚠️   DEMO / TESTING USE ONLY                        ║"
echo "  ║  Press ENTER to continue... Ctrl+C to cancel.       ║"
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
if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -qE '^filebrowser$'; then
    warn "Removing existing container: filebrowser"
    docker rm -f filebrowser 2>/dev/null || true
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
FB_DIR="/root/docker/filebrowser"
if [ -d "$FB_DIR" ]; then
    warn "Removing old directory $FB_DIR..."
    rm -rf "$FB_DIR"
fi
mkdir -p "$FB_DIR/srv" "$FB_DIR/database" "$FB_DIR/config"
touch "$FB_DIR/database/filebrowser.db"
cd "$FB_DIR" || error "Cannot navigate to $FB_DIR"
info "Directory ready: $FB_DIR"

section "Step 6: Creating docker-compose.yml"
cat > "$FB_DIR/docker-compose.yml" <<EOF
services:
  filebrowser:
    image: filebrowser/filebrowser:s6
    container_name: filebrowser
    restart: unless-stopped
    ports:
      - "8080:80"
    volumes:
      - ./srv:/srv
      - ./database/filebrowser.db:/database/filebrowser.db
      - ./config:/config
    environment:
      PUID: 1000
      PGID: 1000
EOF
info "docker-compose.yml created."

section "Step 7: Starting FileBrowser"
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    docker compose up -d && break
    warn "Docker pull failed on attempt $attempt/$MAX_RETRIES."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed to start after $MAX_RETRIES attempts."
done

section "Step 8: Verifying Container"
sleep 5
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^filebrowser$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs filebrowser"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for FileBrowser to be ready on port 8080..."
HEALTH_OK=0
for i in $(seq 1 12); do
    if curl -s --max-time 5 http://127.0.0.1:8080 &>/dev/null; then
        info "Port 8080 is responding — FileBrowser is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done
[ "$HEALTH_OK" -eq 0 ] && warn "FileBrowser may still be initializing. Check: docker logs filebrowser"

section "Step 10: Opening Firewall Port 8080"
if command -v ufw &> /dev/null; then
    ufw allow 8080/tcp
    info "UFW: port 8080/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open FileBrowser in your browser:             ║"
echo "  ║      👉  http://$SERVER_IP:8080                     ║"
echo "  ║                                                      ║"
echo "  ║  🔑  Default Login:                                 ║"
echo "  ║      Username : admin                               ║"
echo "  ║      Password : admin                               ║"
echo "  ║      (Change password immediately after login!)     ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║  🚀  Need production setup?                         ║"
echo "  ║      👨‍💻  Mohammed Ali Elshikh | prismatechwork.com  ║"
echo "  ║  ☕  USDT TRC-20: TCSZTkXvhibdrFre5sdTsFLRQ6d6yQkd2i ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
