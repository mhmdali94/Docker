#!/bin/bash
#
# ============================================================
#   Pritunl VPN Auto-Installer
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
echo "  ║       Pritunl VPN Auto-Installer                 ║"
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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^pritunl$|^pritunl-mongo$' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing Pritunl containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
PT_DIR="/root/docker/pritunl"
if [ -d "$PT_DIR" ]; then
    warn "Removing old directory $PT_DIR..."
    rm -rf "$PT_DIR"
fi
mkdir -p "$PT_DIR"
cd "$PT_DIR" || error "Cannot navigate to $PT_DIR"
info "Directory ready: $PT_DIR"

section "Step 6: Enabling TUN Device"
if [ ! -c /dev/net/tun ]; then
    mkdir -p /dev/net
    mknod /dev/net/tun c 10 200
    chmod 600 /dev/net/tun
    info "TUN device created."
else
    info "TUN device exists. OK."
fi

section "Step 7: Generating docker-compose.yml"
MONGO_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 24)

cat > "$PT_DIR/docker-compose.yml" <<EOF
services:
  pritunl-mongo:
    image: mongo:4.4
    container_name: pritunl-mongo
    restart: unless-stopped
    volumes:
      - ./mongo:/data/db
    networks:
      - pritunl-net

  pritunl:
    image: jippi/pritunl:latest
    container_name: pritunl
    restart: unless-stopped
    privileged: true
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
    ports:
      - "80:80"
      - "443:443"
      - "1194:1194/udp"
      - "1194:1194/tcp"
    volumes:
      - ./data:/var/lib/pritunl
    environment:
      - PRITUNL_MONGODB_URI=mongodb://pritunl-mongo:27017/pritunl
    depends_on:
      - pritunl-mongo
    networks:
      - pritunl-net

networks:
  pritunl-net:
    driver: bridge
EOF
info "docker-compose.yml created."

section "Step 8: Starting Pritunl"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 9: Verifying Containers"
sleep 8
RUNNING=$(docker ps --format '{{.Names}}' | grep -E 'pritunl' || true)
if [ -z "$RUNNING" ]; then
    warn "Containers may not have started. Check: docker logs pritunl"
else
    info "Containers running: $RUNNING"
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Pritunl in your browser:                 ║"
echo "  ║      👉  https://$SERVER_IP"
echo "  ║                                                      ║"
echo "  ║  🔑  Get setup key & default credentials:          ║"
echo "  ║      docker exec pritunl pritunl setup-key          ║"
echo "  ║      docker exec pritunl pritunl default-password   ║"
echo "  ║                                                      ║"
echo "  ║  📡  Ports: 443 (Web UI + VPN), 1194 (UDP/TCP)    ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  Accept the self-signed SSL cert in browser.   ║"
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
