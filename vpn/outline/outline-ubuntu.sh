#!/bin/bash
#
# ============================================================
#   Outline VPN Server Auto-Installer
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
echo "  ║       Outline VPN Server Auto-Installer          ║"
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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^outline' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing Outline containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
OL_DIR="/root/docker/outline"
if [ -d "$OL_DIR" ]; then
    warn "Removing old directory $OL_DIR..."
    rm -rf "$OL_DIR"
fi
mkdir -p "$OL_DIR/shadowbox-config" "$OL_DIR/shadowbox-logs"
cd "$OL_DIR" || error "Cannot navigate to $OL_DIR"
info "Directory ready: $OL_DIR"

section "Step 6: Detecting Server IP"
WAN_IP=$(curl -4 -s --max-time 5 https://ifconfig.me || curl -4 -s --max-time 5 https://api4.ipify.org || hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
info "Detected IP: $WAN_IP"

section "Step 7: Generating Keys & docker-compose.yml"
SECRET_KEY=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)
API_PORT=8092
KEYS_PORT=12345

cat > "$OL_DIR/shadowbox-config/shadowbox_config.json" <<EOF
{
  "accessKeyDataLimit": {"bytes": 0},
  "hostname": "$WAN_IP"
}
EOF

cat > "$OL_DIR/docker-compose.yml" <<EOF
services:
  outline-shadowbox:
    image: quay.io/outline/shadowbox:stable
    container_name: outline-shadowbox
    restart: unless-stopped
    network_mode: host
    volumes:
      - ./shadowbox-config:/opt/outline/persisted-state
      - ./shadowbox-logs:/var/log/outline
    environment:
      - SB_API_PORT=$API_PORT
      - SB_API_PREFIX=$SECRET_KEY
      - SB_KEYS_PORT=$KEYS_PORT
      - SB_CERTIFICATE_FILE=/opt/outline/persisted-state/shadowbox-selfsigned.crt
      - SB_PRIVATE_KEY_FILE=/opt/outline/persisted-state/shadowbox-selfsigned.key
EOF
info "docker-compose.yml created."

section "Step 8: Starting Outline"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 9: Verifying Container"
sleep 5
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^outline' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs outline-shadowbox"
else
    info "Container running: $RUNNING"
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
API_URL="https://$WAN_IP:$API_PORT/$SECRET_KEY"
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  📋  Management API URL (save this!):              ║"
echo "  ║      $API_URL"
echo "  ║                                                      ║"
echo "  ║  🖥️   Manage via Outline Manager desktop app:       ║"
echo "  ║      https://getoutline.org/get-started/#step-3     ║"
echo "  ║      Paste the API URL above into the manager.      ║"
echo "  ║                                                      ║"
echo "  ║  📡  VPN Keys Port : $KEYS_PORT"
echo "  ║  ⚙️   API Port      : $API_PORT"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh | prismatechwork.com                   ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
