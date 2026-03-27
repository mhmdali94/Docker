#!/bin/bash
#
# ============================================================
#   SoftEther VPN Server Auto-Installer
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
echo "  ║       SoftEther VPN Server Auto-Installer        ║"
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

section "Step 4: Cleaning Up Existing Containers"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^softether$' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing SoftEther containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
SE_DIR="/root/docker/softether"
if [ -d "$SE_DIR" ]; then
    warn "Removing old directory $SE_DIR..."
    rm -rf "$SE_DIR"
fi
mkdir -p "$SE_DIR"
cd "$SE_DIR" || error "Cannot navigate to $SE_DIR"
info "Directory ready: $SE_DIR"

section "Step 6: Generating docker-compose.yml"
cat > "$SE_DIR/docker-compose.yml" <<EOF
services:
  softether:
    image: siomiz/softethervpn:latest
    container_name: softether
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
    ports:
      - "500:500/udp"
      - "4500:4500/udp"
      - "1701:1701/tcp"
      - "1194:1194/udp"
      - "443:443/tcp"
      - "5555:5555/tcp"
    volumes:
      - ./vpn_server.config:/usr/vpnserver/vpn_server.config
    environment:
      - SPW=
      - HPW=
EOF
info "docker-compose.yml created."

section "Step 7: Starting SoftEther VPN"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 8: Verifying Container"
sleep 5
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^softether$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs softether"
else
    info "Container running: $RUNNING"
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🖥️   Manage via SoftEther VPN Server Manager:      ║"
echo "  ║      Connect to: $SERVER_IP:5555"
echo "  ║                                                      ║"
echo "  ║  📡  Supported Protocols:                           ║"
echo "  ║      • L2TP/IPsec   → ports 500/UDP, 4500/UDP      ║"
echo "  ║      • OpenVPN      → port  1194/UDP               ║"
echo "  ║      • SSTP         → port  443/TCP                ║"
echo "  ║      • SoftEther    → port  5555/TCP               ║"
echo "  ║                                                      ║"
echo "  ║  🔑  Set admin password on first connection via     ║"
echo "  ║      SoftEther VPN Server Manager (Windows/Linux).  ║"
echo "  ║                                                      ║"
echo "  ║  💾  Download Manager:                              ║"
echo "  ║      https://www.softether-download.com             ║"
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
