#!/bin/bash
#
# ============================================================
#   3X-UI (V2Ray/Xray Panel) Auto-Installer
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
echo "  ║       3X-UI (V2Ray/Xray Panel) Auto-Installer   ║"
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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^3x-ui$' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing 3X-UI containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
XUI_DIR="/root/docker/3x-ui"
if [ -d "$XUI_DIR" ]; then
    warn "Removing old directory $XUI_DIR..."
    rm -rf "$XUI_DIR"
fi
mkdir -p "$XUI_DIR"
cd "$XUI_DIR" || error "Cannot navigate to $XUI_DIR"
info "Directory ready: $XUI_DIR"

section "Step 6: Generating Credentials & docker-compose.yml"
XUI_USER=$(tr -dc 'a-z0-9' < /dev/urandom | head -c 10)
XUI_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
XUI_PORT=2053
info "Username : $XUI_USER"
info "Password : $XUI_PASS"

cat > "$XUI_DIR/docker-compose.yml" <<EOF
services:
  3x-ui:
    image: ghcr.io/mhsanaei/3x-ui:latest
    container_name: 3x-ui
    restart: unless-stopped
    network_mode: host
    volumes:
      - ./db:/etc/x-ui
      - ./certs:/root/certs
    environment:
      - XRAY_VMESS_AEAD_FORCED=false
EOF
info "docker-compose.yml created."

section "Step 7: Starting 3X-UI"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

info "Waiting for 3X-UI to initialize database..."
sleep 8

info "Setting credentials via CLI..."
docker exec 3x-ui x-ui setting -username "$XUI_USER" -password "$XUI_PASS" -port "$XUI_PORT" || \
    error "Failed to set 3X-UI credentials. Check: docker logs 3x-ui"

info "Restarting to apply credentials..."
docker compose restart 2>/dev/null || docker-compose restart

section "Step 8: Opening Firewall Port $XUI_PORT"
if command -v ufw &> /dev/null; then
    ufw allow "$XUI_PORT"/tcp
    info "UFW: port $XUI_PORT/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

section "Step 9: Verifying Container"
sleep 5
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^3x-ui$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs 3x-ui"
else
    info "Container running: $RUNNING"
fi

section "Step 10: Health Check"
info "Waiting for 3X-UI to be ready on port $XUI_PORT..."
HEALTH_OK=0
for i in $(seq 1 12); do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 http://127.0.0.1:$XUI_PORT 2>/dev/null || echo "000")
    if echo "$STATUS" | grep -qE '^(200|301|302|303)$'; then
        info "Port $XUI_PORT is responding (HTTP $STATUS) — 3X-UI is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 $XUI_PORT 2>/dev/null; then
        warn "Port $XUI_PORT is open but HTTP did not respond. Service may still be starting."
        warn "Check logs: docker logs 3x-ui"
    else
        warn "Port $XUI_PORT is NOT responding after 60s."
        warn "Check logs: docker logs 3x-ui"
        docker logs --tail 20 3x-ui 2>&1 || true
    fi
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open 3X-UI Panel in your browser:             ║"
echo "  ║      👉  http://$SERVER_IP:$XUI_PORT                ║"
echo "  ║                                                      ║"
echo "  ║  🔑  Login Credentials (save these!):              ║"
echo "  ║      Username : $XUI_USER                           ║"
echo "  ║      Password : $XUI_PASS                           ║"
echo "  ║                                                      ║"
echo "  ║  📡  Protocols supported: VMess, VLESS, Trojan,    ║"
echo "  ║      Shadowsocks, Socks, HTTP, WireGuard            ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  Uses host network mode — inbound ports are     ║"
echo "  ║      opened directly on the host.                   ║"
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
