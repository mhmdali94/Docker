#!/bin/bash
#
# ============================================================
#   AdGuard Home Auto-Installer
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
echo "  ║       AdGuard Home Auto-Installer                ║"
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

section "Step 4: Freeing Port 53 (systemd-resolved)"
if systemctl is-active --quiet systemd-resolved; then
    warn "Disabling systemd-resolved stub listener to free port 53..."
    mkdir -p /etc/systemd/resolved.conf.d
    cat > /etc/systemd/resolved.conf.d/adguardhome.conf <<EOF
[Resolve]
DNSStubListener=no
EOF
    systemctl restart systemd-resolved
    info "Port 53 freed."
else
    info "systemd-resolved not active — port 53 should be free."
fi

section "Step 5: Cleaning Up Existing Containers"
if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -qE '^adguardhome$'; then
    warn "Removing existing container: adguardhome"
    docker rm -f adguardhome 2>/dev/null || true
fi
docker network prune -f &>/dev/null || true

section "Step 6: Preparing Directory"
AGH_DIR="/root/docker/adguardhome"
if [ -d "$AGH_DIR" ]; then
    warn "Removing old directory $AGH_DIR..."
    rm -rf "$AGH_DIR"
fi
mkdir -p "$AGH_DIR/work" "$AGH_DIR/conf"
cd "$AGH_DIR" || error "Cannot navigate to $AGH_DIR"
info "Directory ready: $AGH_DIR"

section "Step 7: Creating docker-compose.yml"
cat > "$AGH_DIR/docker-compose.yml" <<EOF
services:
  adguardhome:
    image: adguard/adguardhome:latest
    container_name: adguardhome
    restart: unless-stopped
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "3000:3000/tcp"
      - "80:80/tcp"
      - "443:443/tcp"
    volumes:
      - ./work:/opt/adguardhome/work
      - ./conf:/opt/adguardhome/conf
EOF
info "docker-compose.yml created."

section "Step 8: Starting AdGuard Home"
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    docker compose up -d && break
    warn "Docker pull failed on attempt $attempt/$MAX_RETRIES."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed to start after $MAX_RETRIES attempts."
done

section "Step 9: Verifying Container"
sleep 5
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^adguardhome$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs adguardhome"
else
    info "Container running: $RUNNING"
fi

section "Step 10: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    ufw allow 53/tcp
    ufw allow 53/udp
    ufw allow 3000/tcp
    ufw allow 80/tcp
    info "UFW: ports 53, 3000, 80 opened."
else
    warn "UFW not found — skipping firewall rule."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Complete setup wizard in your browser:        ║"
echo "  ║      👉  http://$SERVER_IP:3000                     ║"
echo "  ║                                                      ║"
echo "  ║  📌  After setup, admin panel will be at:          ║"
echo "  ║      http://$SERVER_IP:80                           ║"
echo "  ║                                                      ║"
echo "  ║  🔒  Set DNS on your devices to: $SERVER_IP         ║"
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
