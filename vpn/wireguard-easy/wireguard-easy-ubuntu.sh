#!/bin/bash
#
# ============================================================
#   WireGuard Easy Auto-Installer
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
echo "  ║       WireGuard Easy Auto-Installer              ║"
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

section "Step 2: Enabling WireGuard Kernel Module"
apt update -y && apt install -y wireguard-tools &>/dev/null || true
modprobe wireguard 2>/dev/null || warn "wireguard module not loaded — may already be built-in."
info "WireGuard module OK."

section "Step 3: Checking Docker"
if ! command -v docker &> /dev/null; then
    warn "Docker not found. Installing..."
    apt update -y && apt install -y docker.io
    systemctl enable --now docker
    info "Docker installed."
else
    info "Docker: $(docker --version)"
fi

section "Step 4: Checking Docker Compose V2"
if ! docker compose version &> /dev/null; then
    warn "Docker Compose V2 not found. Installing..."
    apt update -y && apt install -y docker-compose-v2 || apt install -y docker-compose
    info "Docker Compose installed."
else
    info "Docker Compose: $(docker compose version)"
fi

section "Step 5: Cleaning Up Existing Containers"
if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -qE '^wg-easy$'; then
    warn "Removing existing container: wg-easy"
    docker rm -f wg-easy 2>/dev/null || true
fi
docker network prune -f &>/dev/null || true

section "Step 6: Preparing Directory"
WG_DIR="/root/docker/wireguard-easy"
if [ -d "$WG_DIR" ]; then
    warn "Removing old directory $WG_DIR..."
    rm -rf "$WG_DIR"
fi
mkdir -p "$WG_DIR/data"
cd "$WG_DIR" || error "Cannot navigate to $WG_DIR"
info "Directory ready: $WG_DIR"

section "Step 7: Generating Credentials & docker-compose.yml"
info "Installing apache2-utils for bcrypt hash generation..."
apt install -y apache2-utils &>/dev/null || warn "apache2-utils not installed — hash generation may fail."
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
WG_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
WG_PASS_HASH=$(htpasswd -bnBC 10 "" "$WG_PASS" 2>/dev/null | tr -d ':
' | sed 's/$2y/$2a/' || echo "")
[ -z "$WG_PASS_HASH" ] && error "Failed to generate bcrypt hash. Ensure apache2-utils is installed."
info "WireGuard Host     : $SERVER_IP"
info "Admin Password     : $WG_PASS"

cat > "$WG_DIR/docker-compose.yml" <<EOF
services:
  wg-easy:
    image: ghcr.io/wg-easy/wg-easy:latest
    container_name: wg-easy
    restart: unless-stopped
    ports:
      - "51820:51820/udp"
      - "51821:51821/tcp"
    volumes:
      - ./data:/etc/wireguard
    environment:
      WG_HOST: $SERVER_IP
      PASSWORD_HASH: $WG_PASS_HASH
      WG_DEFAULT_ADDRESS: 10.8.0.x
      WG_DEFAULT_DNS: 1.1.1.1
      WG_MTU: 1420
      WG_ALLOWED_IPS: 0.0.0.0/0
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
      - net.ipv4.ip_forward=1
EOF
info "docker-compose.yml created."

section "Step 8: Starting WireGuard Easy"
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    docker compose up -d && break
    warn "Docker pull failed on attempt $attempt/$MAX_RETRIES."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed to start after $MAX_RETRIES attempts."
done

section "Step 9: Verifying Container"
sleep 5
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^wg-easy$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs wg-easy"
else
    info "Container running: $RUNNING"
fi

section "Step 10: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    ufw allow 51820/udp
    ufw allow 51821/tcp
    info "UFW: ports 51820/udp and 51821/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open WireGuard Easy in your browser:          ║"
echo "  ║      👉  http://$SERVER_IP:51821                    ║"
echo "  ║                                                      ║"
echo "  ║  🔑  Login Credentials (save these!):              ║"
echo "  ║      Password : $WG_PASS                            ║"
echo "  ║                                                      ║"
echo "  ║  🔒  VPN endpoint: $SERVER_IP:51820                 ║"
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
