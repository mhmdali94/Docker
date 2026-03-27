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
echo "  ║       Made by: Mohammed Ali Elshikh | prismatechwork.com                ║"
echo "  ║                                                  ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️         ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""

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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E 'filebrowser' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing FileBrowser containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
FILEBROWSER_DIR="/root/docker/filebrowser"
if [ -d "$FILEBROWSER_DIR" ]; then
    warn "Removing old directory $FILEBROWSER_DIR..."
    rm -rf "$FILEBROWSER_DIR"
fi
mkdir -p "$FILEBROWSER_DIR"
cd "$FILEBROWSER_DIR" || error "Cannot navigate to $FILEBROWSER_DIR"
info "Directory ready: $FILEBROWSER_DIR"

section "Step 6: Generating docker-compose.yml"
cat > "$FILEBROWSER_DIR/docker-compose.yml" <<EOF
services:
  filebrowser:
    image: filebrowser/filebrowser:latest
    container_name: filebrowser
    restart: unless-stopped
    ports:
      - "8082:80"
    volumes:
      - /root:/srv
      - ./database:/database
      - ./config:/config
EOF
info "docker-compose.yml created."

section "Step 7: Starting FileBrowser"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 8: Verifying Container"
sleep 4
RUNNING=$(docker ps --format '{{.Names}}' | grep -E 'filebrowser' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs filebrowser"
else
    info "Container running: $RUNNING"
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open FileBrowser in your browser:             ║"
echo "  ║      👉  http://$SERVER_IP:8082"
echo "  ║                                                      ║"
echo "  ║  🔑  Default Login Credentials:                     ║"
echo "  ║     Username : admin                                ║"
echo "  ║     Password : admin                                ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  Change credentials immediately after login!    ║"
echo "  ║                                                      ║"
echo "  ║  📂  Browse files in: /root                         ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh | prismatechwork.com                   ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
