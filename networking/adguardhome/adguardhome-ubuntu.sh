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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E 'adguardhome' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing AdGuard Home containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
ADGUARD_DIR="/root/docker/adguardhome"
if [ -d "$ADGUARD_DIR" ]; then
    warn "Removing old directory $ADGUARD_DIR..."
    rm -rf "$ADGUARD_DIR"
fi
mkdir -p "$ADGUARD_DIR/work" "$ADGUARD_DIR/conf"
cd "$ADGUARD_DIR" || error "Cannot navigate to $ADGUARD_DIR"
info "Directory ready: $ADGUARD_DIR"

section "Step 6: Freeing Port 53"
if ss -tlunp 2>/dev/null | grep -q ':53 '; then
    warn "Port 53 is in use — disabling systemd-resolved DNS stub listener..."
    mkdir -p /etc/systemd/resolved.conf.d
    cat > /etc/systemd/resolved.conf.d/adguard.conf <<RESOLVCONF
[Resolve]
DNSStubListener=no
RESOLVCONF
    systemctl restart systemd-resolved
    # Point /etc/resolv.conf at a real upstream so the host still resolves
    rm -f /etc/resolv.conf
    echo "nameserver 1.1.1.1" > /etc/resolv.conf
    info "systemd-resolved stub listener disabled. Port 53 is now free. ✅"
else
    info "Port 53 is free. OK."
fi

section "Step 7: Opening Firewall Ports"
if command -v ufw &>/dev/null && ufw status | grep -qi "active"; then
    ufw allow 53/tcp  comment 'AdGuard DNS'
    ufw allow 53/udp  comment 'AdGuard DNS'
    ufw allow 3000/tcp comment 'AdGuard Setup UI'
    ufw allow 8083/tcp comment 'AdGuard Web UI'
    ufw allow 443/tcp  comment 'AdGuard HTTPS/DoH'
    ufw allow 443/udp  comment 'AdGuard DoQ'
    ufw reload
    info "UFW rules added. ✅"
else
    iptables -I INPUT -p tcp --dport 53   -j ACCEPT
    iptables -I INPUT -p udp --dport 53   -j ACCEPT
    iptables -I INPUT -p tcp --dport 3000 -j ACCEPT
    iptables -I INPUT -p tcp --dport 8083 -j ACCEPT
    iptables -I INPUT -p tcp --dport 443  -j ACCEPT
    iptables -I INPUT -p udp --dport 443  -j ACCEPT
    iptables-save > /etc/iptables/rules.v4 2>/dev/null || true
    info "iptables rules added. ✅"
fi

section "Step 8: Generating docker-compose.yml"
cat > "$ADGUARD_DIR/docker-compose.yml" <<EOF
services:
  adguardhome:
    image: adguard/adguardhome:latest
    container_name: adguardhome
    restart: unless-stopped
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "8083:80/tcp"
      - "443:443/tcp"
      - "443:443/udp"
      - "3000:3000/tcp"
    volumes:
      - ./work:/opt/adguardhome/work
      - ./conf:/opt/adguardhome/conf
EOF
info "docker-compose.yml created."

section "Step 9: Starting AdGuard Home"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 10: Verifying Container"
sleep 4
RUNNING=$(docker ps --format '{{.Names}}' | grep -E 'adguardhome' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs adguardhome"
else
    info "Container running: $RUNNING"
fi

section "Step 11: Health Check"
info "Waiting for AdGuard Home to be ready on port 3000..."
HEALTH_OK=0
for i in $(seq 1 12); do
    if curl -sf --max-time 3 http://127.0.0.1:3000 &>/dev/null; then
        info "Port 3000 is responding — AdGuard Home is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 3000 2>/dev/null; then
        warn "Port 3000 is open but HTTP did not respond. Service may still be starting."
        warn "Check logs: docker logs adguardhome"
    else
        warn "Port 3000 is NOT responding after 60s."
        warn "Check logs: docker logs adguardhome"
        docker logs --tail 20 adguardhome 2>&1 || true
    fi
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open AdGuard Home in your browser:            ║"
echo "  ║      👉  http://$SERVER_IP:3000"
echo "  ║                                                      ║"
echo "  ║  🔑  Complete the initial setup wizard:            ║"
echo "  ║      - Create admin account                        ║"
echo "  ║      - Configure upstream DNS servers              ║"
echo "  ║      - Set up filters                              ║"
echo "  ║                                                      ║"
echo "  ║  📱  Use this server as DNS on your devices:      ║"
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
