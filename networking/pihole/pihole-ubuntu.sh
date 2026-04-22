#!/bin/bash
#
# ============================================================
#   Pi-hole Auto-Installer
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
echo "  ║       Pi-hole Auto-Installer                     ║"
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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E 'pihole' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing Pi-hole containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
PIHOLE_DIR="/root/docker/pihole"
if [ -d "$PIHOLE_DIR" ]; then
    warn "Removing old directory $PIHOLE_DIR..."
    rm -rf "$PIHOLE_DIR"
fi
mkdir -p "$PIHOLE_DIR/etc-pihole" "$PIHOLE_DIR/etc-dnsmasq.d"
cd "$PIHOLE_DIR" || error "Cannot navigate to $PIHOLE_DIR"
info "Directory ready: $PIHOLE_DIR"

section "Step 6: Freeing Port 53"
info "Stopping and disabling systemd-resolved to free port 53..."
systemctl stop systemd-resolved    2>/dev/null || true
systemctl disable systemd-resolved 2>/dev/null || true
rm -f /etc/resolv.conf
cat > /etc/resolv.conf <<RESOLV
nameserver 1.1.1.1
nameserver 8.8.8.8
RESOLV
fuser -k 53/tcp 2>/dev/null || true
fuser -k 53/udp 2>/dev/null || true
sleep 2
if ss -tlnp | grep -q ':53' || ss -ulnp | grep -q ':53'; then
    error "Port 53 still occupied. Run: ss -tlunp | grep ':53'"
fi
info "Port 53 is free. ✅"

section "Step 7: Opening Firewall Ports"
if command -v ufw &>/dev/null && ufw status | grep -qi "active"; then
    ufw allow 53/tcp  comment 'Pi-hole DNS'
    ufw allow 53/udp  comment 'Pi-hole DNS'
    ufw allow 8084/tcp comment 'Pi-hole Web UI'
    ufw reload
    info "UFW rules added. ✅"
else
    iptables -I INPUT -p tcp --dport 53   -j ACCEPT
    iptables -I INPUT -p udp --dport 53   -j ACCEPT
    iptables -I INPUT -p tcp --dport 8084 -j ACCEPT
    iptables-save > /etc/iptables/rules.v4 2>/dev/null || true
    info "iptables rules added. ✅"
fi

section "Step 8: Generating Password"
WEB_PASSWORD=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
info "Admin password generated."

section "Step 9: Generating docker-compose.yml"
cat > "$PIHOLE_DIR/docker-compose.yml" <<EOF
services:
  pihole:
    image: pihole/pihole:latest
    container_name: pihole
    restart: unless-stopped
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "8084:80/tcp"
    environment:
      TZ: 'UTC'
      WEBPASSWORD: '$WEB_PASSWORD'
    volumes:
      - ./etc-pihole:/etc/pihole
      - ./etc-dnsmasq.d:/etc/dnsmasq.d
EOF
info "docker-compose.yml created."

section "Step 10: Starting Pi-hole"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 11: Verifying Container"
sleep 5
RUNNING=$(docker ps --format '{{.Names}}' | grep -E 'pihole' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs pihole"
else
    info "Container running: $RUNNING"
fi

section "Step 12: Health Check"
info "Waiting for Pi-hole to be ready on port 8084..."
HEALTH_OK=0
for i in $(seq 1 12); do
    if curl -sf --max-time 3 http://127.0.0.1:8084/admin &>/dev/null; then
        info "Port 8084 is responding — Pi-hole is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 8084 2>/dev/null; then
        warn "Port 8084 is open but HTTP did not respond. Service may still be starting."
        warn "Check logs: docker logs pihole"
    else
        warn "Port 8084 is NOT responding after 60s."
        warn "Check logs: docker logs pihole"
        docker logs --tail 20 pihole 2>&1 || true
    fi
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Pi-hole Admin in your browser:           ║"
echo "  ║      👉  http://$SERVER_IP:8084/admin"
echo "  ║                                                      ║"
echo "  ║  🔑  Login Credentials:                             ║"
echo "  ║      Password: $WEB_PASSWORD"
echo "  ║                                                      ║"
echo "  ║  📱  Configure DNS on your devices:                 ║"
echo "  ║      DNS Server: $SERVER_IP"
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
