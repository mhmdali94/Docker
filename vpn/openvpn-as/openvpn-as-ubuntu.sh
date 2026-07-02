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

section "Step 4: Creating TUN device"
if [ ! -c /dev/net/tun ]; then
    mkdir -p /dev/net
    mknod /dev/net/tun c 10 200
    chmod 600 /dev/net/tun
    info "TUN device created."
else
    info "TUN device already exists."
fi

section "Step 5: Cleaning Up Existing Containers"
if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -qE '^openvpn-as$'; then
    warn "Removing existing container: openvpn-as"
    docker rm -f openvpn-as 2>/dev/null || true
fi
docker network prune -f &>/dev/null || true

section "Step 6: Preparing Directory"
OVPN_DIR="/root/docker/openvpn-as"
if [ -d "$OVPN_DIR" ]; then
    warn "Removing old directory $OVPN_DIR..."
    rm -rf "$OVPN_DIR"
fi
mkdir -p "$OVPN_DIR/config"
cd "$OVPN_DIR" || error "Cannot navigate to $OVPN_DIR"
info "Directory ready: $OVPN_DIR"

section "Step 7: Creating docker-compose.yml"
cat > "$OVPN_DIR/docker-compose.yml" <<EOF
services:
  openvpn-as:
    image: openvpn/openvpn-as:latest
    container_name: openvpn-as
    restart: unless-stopped
    ports:
      - "943:943"
      - "9443:443"
      - "1194:1194/udp"
    volumes:
      - ./config:/openvpn
    cap_add:
      - NET_ADMIN
      - MKNOD
    devices:
      - /dev/net/tun:/dev/net/tun
EOF
info "docker-compose.yml created."

section "Step 8: Starting OpenVPN Access Server"
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    docker compose up -d && break
    warn "Docker pull failed on attempt $attempt/$MAX_RETRIES."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed to start after $MAX_RETRIES attempts."
done

section "Step 9: Verifying Container"
sleep 15
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^openvpn-as$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs openvpn-as"
else
    info "Container running: $RUNNING"
fi

section "Step 10: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    ufw allow 943/tcp
    ufw allow 9443/tcp
    ufw allow 1194/udp
    info "UFW: ports 943/tcp, 9443/tcp, 1194/udp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open OpenVPN Admin in your browser:           ║"
echo "  ║      👉  https://$SERVER_IP:943/admin               ║"
echo "  ║                                                      ║"
echo "  ║  🔑  Admin user: openvpn — password in logs:       ║"
echo "  ║      docker logs openvpn-as 2>&1 | grep -i 'pass'  ║"
echo "  ║                                                      ║"
echo "  ║  🔒  VPN client downloads at:                      ║"
echo "  ║      https://$SERVER_IP:943                         ║"
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
