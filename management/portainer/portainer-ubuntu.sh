#!/bin/bash
#
# ============================================================
#   Portainer-CE Auto-Installer
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
echo "  ║       Portainer-CE Auto-Installer                ║"
echo "  ║       Made by: Mohammed Ali Elshikh             ║"
echo "  ║       prismatechwork.com                        ║"
echo "  ║                                                  ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️         ║"
echo "  ╚══════════════════════════════════════════════════╝"
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

section "Step 3: Cleaning Up Existing Container"
if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -qE '^portainer$'; then
    warn "Removing existing container: portainer"
    docker rm -f portainer 2>/dev/null || true
fi

section "Step 4: Creating Volume"
docker volume create portainer_data &>/dev/null || true
info "Volume portainer_data ready."

section "Step 5: Starting Portainer"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)

MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    docker run -d \
        --name portainer \
        --restart unless-stopped \
        -p 8000:8000 \
        -p 9443:9443 \
        -p 9000:9000 \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v portainer_data:/data \
        portainer/portainer-ce:latest && break
    warn "Docker pull failed on attempt $attempt/$MAX_RETRIES."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed to start after $MAX_RETRIES attempts."
done

section "Step 6: Verifying Container"
sleep 5
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^portainer$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs portainer"
else
    info "Container running: $RUNNING"
fi

section "Step 7: Health Check"
info "Waiting for Portainer to be ready on port 9000..."
HEALTH_OK=0
for i in $(seq 1 12); do
    if curl -sk --max-time 5 http://127.0.0.1:9000 &>/dev/null; then
        info "Port 9000 is responding — Portainer is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    warn "Portainer may still be initializing. Check: docker logs portainer"
fi

section "Step 8: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    ufw allow 9000/tcp
    ufw allow 9443/tcp
    info "UFW: ports 9000/tcp and 9443/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

section "Step 9: Retrieving Setup Token"
info "Reading Portainer setup token from container logs..."

# Portainer CE log format: | setup_token=<64-char hex>
SETUP_TOKEN=""
for i in $(seq 1 24); do
    SETUP_TOKEN=$(docker logs portainer 2>&1 | grep -oP 'setup_token=\K[0-9a-f]+' | tail -1 || true)
    if [ -n "$SETUP_TOKEN" ]; then
        info "Setup token retrieved."
        break
    fi
    echo -n "  Attempt $i/24 — waiting for token in logs..."
    sleep 5
    echo " retrying"
done

[ -z "$SETUP_TOKEN" ] && SETUP_TOKEN="(not found — check: docker logs portainer | grep -i token)"

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Portainer in your browser:                ║"
echo "  ║      HTTP  👉  http://$SERVER_IP:9000"
echo "  ║      HTTPS 👉  https://$SERVER_IP:9443"
echo "  ║                                                      ║"
echo "  ║  🔑  Setup Token (use on first login):              ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  $SETUP_TOKEN"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  ⚠️  Save this token — it will NOT be shown again!  ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
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
