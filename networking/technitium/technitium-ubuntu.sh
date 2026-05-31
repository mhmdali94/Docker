#!/bin/bash
#
# ============================================================
#   Technitium DNS Server Auto-Installer
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
echo "  ║     Technitium DNS Server Auto-Installer         ║"
echo "  ║     Made by: Mohammed Ali Elshikh               ║"
echo "  ║     prismatechwork.com                          ║"
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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^technitium-dns$' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing Technitium DNS containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
TECH_DIR="/root/docker/technitium"
if [ -d "$TECH_DIR" ]; then
    warn "Removing old directory $TECH_DIR..."
    rm -rf "$TECH_DIR"
fi
mkdir -p "$TECH_DIR/data"
cd "$TECH_DIR" || error "Cannot navigate to $TECH_DIR"
info "Directory ready: $TECH_DIR"

info "Checking for systemd-resolved conflict on port 53..."
if systemctl is-active --quiet systemd-resolved 2>/dev/null; then
    warn "systemd-resolved is running and occupying port 53. Disabling it..."
    systemctl disable --now systemd-resolved
    rm -f /etc/resolv.conf
    echo "nameserver 8.8.8.8" > /etc/resolv.conf
    info "systemd-resolved stopped. Using 8.8.8.8 as temporary DNS."
fi

section "Step 6: Generating Credentials & docker-compose.yml"
TECH_PASS=$(tr -dc 'A-Za-z0-9!@#$%' < /dev/urandom | head -c 20)
info "Admin User     : admin"
info "Admin Password : $TECH_PASS"

cat > "$TECH_DIR/docker-compose.yml" <<EOF
services:
  technitium-dns:
    image: technitium/dns-server:latest
    container_name: technitium-dns
    restart: unless-stopped
    ports:
      - "53:53/udp"
      - "53:53/tcp"
      - "5380:5380"
    environment:
      DNS_SERVER_DOMAIN: dns.local
      DNS_SERVER_ADMIN_PASSWORD: $TECH_PASS
    volumes:
      - ./data:/etc/dns
    cap_add:
      - NET_BIND_SERVICE
EOF
info "docker-compose.yml created."

section "Step 7: Starting Technitium DNS Server"
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    if docker compose version &> /dev/null; then
        docker compose up -d && break
    else
        docker-compose up -d && break
    fi
    warn "Docker pull failed on attempt $attempt/$MAX_RETRIES (registry may be temporarily unavailable)."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed to start after $MAX_RETRIES attempts. Run manually: cd $PWD && docker compose up -d"
done

section "Step 8: Verifying Container"
sleep 5
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^technitium-dns$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs technitium-dns"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for Technitium DNS to be ready on port 5380..."
HEALTH_OK=0
for i in $(seq 1 12); do
    if curl -s --max-time 3 http://127.0.0.1:5380 &>/dev/null; then
        info "Port 5380 is responding — Technitium DNS is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 5380 2>/dev/null; then
        warn "Port 5380 is open but not fully ready."
        warn "Check logs: docker logs technitium-dns"
    else
        warn "Port 5380 is NOT responding after 60s."
        docker logs --tail 20 technitium-dns 2>&1 || true
    fi
fi

if ! nc -z 127.0.0.1 53 2>/dev/null; then
    warn "Port 53 (DNS) is NOT open — may conflict with systemd-resolved."
    warn "To fix: systemctl disable --now systemd-resolved"
fi

section "Step 10: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    ufw allow 53/tcp
    ufw allow 53/udp
    ufw allow 5380/tcp
    info "UFW: ports 53 (TCP+UDP) and 5380/tcp opened."
else
    warn "UFW not found — skipping firewall rules."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Technitium DNS in your browser:         ║"
echo "  ║      👉  http://$SERVER_IP:5380"
echo "  ║                                                      ║"
echo "  ║  🔑  Login Credentials (save these!):              ║"
echo "  ║      Username : admin"
echo "  ║      Password : $TECH_PASS"
echo "  ║                                                      ║"
echo "  ║  🔎  Test DNS: dig @$SERVER_IP google.com         ║"
echo "  ║  📡  Point devices to: $SERVER_IP (DNS server)    ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║                                                      ║"
echo "  ║  🚀  Need production setup?                         ║"
echo "  ║      👨‍💻  Mohammed Ali Elshikh                      ║"
echo "  ║      🌐  prismatechwork.com                         ║"
echo "  ║                                                      ║"
echo "  ║  ☕  Support this script — USDT (TRC-20 only):     ║"
echo "  ║      TCSZTkXvhibdrFre5sdTsFLRQ6d6yQkd2i           ║"
echo "  ║                                                      ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
