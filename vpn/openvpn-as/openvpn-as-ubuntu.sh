#!/bin/bash
#
# ============================================================
#   OpenVPN Access Server Auto-Installer
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
echo "  ║       OpenVPN Access Server Auto-Installer       ║"
echo "  ║       Made by: Mohammed Ali Elshikh | prismatechwork.com                ║"
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

section "Step 4: Enabling TUN Device"
if [ ! -c /dev/net/tun ]; then
    warn "TUN device not found. Creating..."
    mkdir -p /dev/net
    mknod /dev/net/tun c 10 200
    chmod 600 /dev/net/tun
    info "TUN device created."
else
    info "TUN device exists. OK."
fi

section "Step 5: Cleaning Up Existing Containers"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^openvpn-as$' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing OpenVPN AS containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 6: Preparing Directory"
OVPN_DIR="/root/docker/openvpn-as"
if [ -d "$OVPN_DIR" ]; then
    warn "Removing old directory $OVPN_DIR..."
    rm -rf "$OVPN_DIR"
fi
mkdir -p "$OVPN_DIR"
cd "$OVPN_DIR" || error "Cannot navigate to $OVPN_DIR"
info "Directory ready: $OVPN_DIR"

section "Step 7: Generating docker-compose.yml"
cat > "$OVPN_DIR/docker-compose.yml" <<EOF
services:
  openvpn-as:
    image: openvpn/openvpn-as:latest
    container_name: openvpn-as
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
    ports:
      - "943:943"
      - "443:443"
      - "1194:1194/udp"
    volumes:
      - ./data:/openvpn
    environment:
      - PGID=1000
      - PUID=1000
      - TZ=UTC
EOF
info "docker-compose.yml created."

section "Step 8: Starting OpenVPN Access Server"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 9: Verifying Container"
sleep 8
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^openvpn-as$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs openvpn-as"
else
    info "Container running: $RUNNING"
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Admin Web UI:                                  ║"
echo "  ║      👉  https://$SERVER_IP:943/admin"
echo "  ║                                                      ║"
echo "  ║  👤  Client Portal:                                 ║"
echo "  ║      👉  https://$SERVER_IP:943"
echo "  ║                                                      ║"
echo "  ║  🔑  Default Login Credentials:                     ║"
echo "  ║      Username : openvpn                             ║"
echo "  ║      Password : (auto-set on first boot)            ║"
echo "  ║                                                      ║"
echo "  ║  📋  To get/set the admin password run:            ║"
echo "  ║      docker exec -it openvpn-as passwd openvpn     ║"
echo "  ║                                                      ║"
echo "  ║  📡  Ports: 943 (Web UI), 443 (TCP), 1194 (UDP)   ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  Accept the self-signed SSL cert in browser.   ║"
echo "  ║  ⚠️  Free tier allows up to 2 VPN connections.     ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh | prismatechwork.com                   ║"
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
