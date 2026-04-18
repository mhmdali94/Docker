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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^wireguard-easy$' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing WireGuard Easy containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
WG_DIR="/root/docker/wireguard-easy"
if [ -d "$WG_DIR" ]; then
    warn "Removing old directory $WG_DIR..."
    rm -rf "$WG_DIR"
fi
mkdir -p "$WG_DIR"
cd "$WG_DIR" || error "Cannot navigate to $WG_DIR"
info "Directory ready: $WG_DIR"

section "Step 6: Detecting Server IP"
WAN_IP=$(curl -4 -s --max-time 5 https://ifconfig.me || curl -4 -s --max-time 5 https://api4.ipify.org || hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
info "Detected IP: $WAN_IP"

section "Step 7: Generating Password & docker-compose.yml"
WG_PASSWORD=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
info "Admin password: $WG_PASSWORD"

# Generate bcrypt hash (wg-easy v14+ requires bcrypt, not sha256)
if ! command -v htpasswd &>/dev/null; then
    apt-get install -y apache2-utils -qq
fi
WG_PASSWORD_HASH=$(htpasswd -bnBC 10 "" "$WG_PASSWORD" | tr -d ':\n')
info "Bcrypt hash generated."

# Docker Compose interpolates $VAR in env_file; escape every $ as $$ so
# the bcrypt literal dollar signs survive and reach the container intact.
WG_PASSWORD_HASH_ESCAPED=$(printf '%s' "$WG_PASSWORD_HASH" | sed 's/\$/\$\$/g')
printf "PASSWORD_HASH=%s\n" "$WG_PASSWORD_HASH_ESCAPED" > "$WG_DIR/wg.env"

cat > "$WG_DIR/docker-compose.yml" <<EOF
services:
  wireguard-easy:
    image: ghcr.io/wg-easy/wg-easy:latest
    container_name: wireguard-easy
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
      - net.ipv4.ip_forward=1
    ports:
      - "51820:51820/udp"
      - "51821:51821/tcp"
    volumes:
      - ./data:/etc/wireguard
    env_file:
      - wg.env
    environment:
      - WG_HOST=$WAN_IP
      - WG_DEFAULT_DNS=1.1.1.1
      - WG_DEFAULT_ADDRESS=10.8.0.x
EOF
info "docker-compose.yml and wg.env created."

section "Step 8: Starting WireGuard Easy"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 9: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    ufw allow 51820/udp
    ufw allow 51821/tcp
    info "UFW: ports 51820/UDP and 51821/TCP opened."
else
    warn "UFW not found — skipping firewall rule."
fi

section "Step 10: Verifying Container"
sleep 4
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^wireguard-easy$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs wireguard-easy"
else
    info "Container running: $RUNNING"
fi

section "Step 11: Health Check"
info "Waiting for WireGuard Easy to be ready on port 51821..."
HEALTH_OK=0
for i in $(seq 1 12); do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 http://127.0.0.1:51821 2>/dev/null || echo "000")
    if echo "$STATUS" | grep -qE '^(200|301|302|303)$'; then
        info "Port 51821 is responding (HTTP $STATUS) — WireGuard Easy is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 51821 2>/dev/null; then
        warn "Port 51821 is open but HTTP did not respond. Service may still be starting."
        warn "Check logs: docker logs wireguard-easy"
    else
        warn "Port 51821 is NOT responding after 60s."
        warn "Check logs: docker logs wireguard-easy"
        docker logs --tail 20 wireguard-easy 2>&1 || true
    fi
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open WireGuard Easy in your browser:          ║"
echo "  ║      👉  http://$SERVER_IP:51821                   ║"
echo "  ║                                                      ║"
echo "  ║  🔑  Admin Password (save this!):                  ║"
echo "  ║      $WG_PASSWORD                                   ║"
echo "  ║                                                      ║"
echo "  ║  🌍  VPN Server (WAN IP): $WAN_IP                  ║"
echo "  ║  📡  VPN Port: 51820/UDP                            ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  Ensure UDP port 51820 is open in your firewall ║"
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
