#!/bin/bash
#
# ============================================================
#   FRP Server Auto-Installer
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
echo "  ║         FRP Server Auto-Installer                ║"
echo "  ║         Made by: Mohammed Ali Elshikh           ║"
echo "  ║         prismatechwork.com                      ║"
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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^frps$' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing container: frps"
    docker rm -f frps 2>/dev/null || true
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
FRP_DIR="/root/docker/frp"
if [ -d "$FRP_DIR" ]; then
    warn "Removing old directory $FRP_DIR..."
    rm -rf "$FRP_DIR"
fi
mkdir -p "$FRP_DIR"
cd "$FRP_DIR" || error "Cannot navigate to $FRP_DIR"
info "Directory ready: $FRP_DIR"

section "Step 6: Generating Credentials & Writing Config"
FRP_TOKEN=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)
FRP_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
info "Dashboard User     : admin"
info "Dashboard Password : $FRP_PASS"
info "Tunnel Token       : $FRP_TOKEN"

cat > "$FRP_DIR/frps.toml" <<EOF
bindPort = 7000
auth.method = "token"
auth.token = "$FRP_TOKEN"

[webServer]
addr = "0.0.0.0"
port = 7500
user = "admin"
password = "$FRP_PASS"
EOF
info "frps.toml created."

cat > "$FRP_DIR/docker-compose.yml" <<'EOF'
services:
  frps:
    image: snowdreamtech/frps:latest
    container_name: frps
    restart: unless-stopped
    ports:
      - "7000:7000"
      - "7500:7500"
    volumes:
      - ./frps.toml:/etc/frp/frps.toml
EOF
info "docker-compose.yml created."

section "Step 7: Starting FRP Server"
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
sleep 8
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^frps$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs frps"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for FRP Dashboard to be ready on port 7500..."
HEALTH_OK=0
for i in $(seq 1 12); do
    if curl -sf --max-time 5 http://127.0.0.1:7500 &>/dev/null; then
        info "Port 7500 is responding — FRP Dashboard is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    warn "FRP may still be starting. Check: docker logs frps"
fi

section "Step 10: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    ufw allow 7000/tcp
    ufw allow 7500/tcp
    info "UFW: ports 7000 and 7500/tcp opened."
else
    warn "UFW not found — skipping firewall rules."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  FRP Dashboard:                               ║"
echo "  ║      👉  http://$SERVER_IP:7500"
echo "  ║                                                      ║"
echo "  ║  🔑  Dashboard Credentials (save these!):          ║"
echo "  ║      Username : admin"
echo "  ║      Password : $FRP_PASS"
echo "  ║                                                      ║"
echo "  ║  🔑  Tunnel Token (for frpc clients):              ║"
echo "  ║      $FRP_TOKEN"
echo "  ║                                                      ║"
echo "  ║  📡  Client bind port : 7000/tcp                   ║"
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
