#!/bin/bash
#
# ============================================================
#   IceHRM Auto-Installer
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
echo "  ║         IceHRM Auto-Installer                    ║"
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
for C in icehrm icehrm-db icehrm-app icehrm-mysql icehrm-worker; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${C}$" || true)
    if [ -n "$EXISTING" ]; then
        warn "Removing existing container: $C"
        docker rm -f "$C" 2>/dev/null || true
    fi
done
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory & Sources"
IH_DIR="/root/docker/icehrm"
if [ -d "$IH_DIR" ]; then
    warn "Removing old directory $IH_DIR..."
    rm -rf "$IH_DIR"
fi
mkdir -p "$IH_DIR"
cd "$IH_DIR" || error "Cannot navigate to $IH_DIR"
if ! command -v git &> /dev/null; then
    warn "git not found. Installing..."
    apt update -y && apt install -y git
fi
info "Cloning IceHRM sources (official repo)..."
git clone --depth 1 https://github.com/gamonoid/icehrm.git "$IH_DIR/src" || error "Failed to clone IceHRM repository."
info "Sources ready: $IH_DIR/src"

section "Step 6: Generating Credentials & .env"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
DB_ROOT=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
info "DB User     : icehrm"
info "DB Password : $DB_PASS"

cat > "$IH_DIR/src/.env" <<EOF
APP_PORT=8126
APP_BASE_URL=http://$SERVER_IP:8126
DB_HOST=mysql
DB_NAME=icehrm
DB_USER=icehrm
DB_PASSWORD=$DB_PASS
DB_ROOT_PASSWORD=$DB_ROOT
EOF
info ".env created."

section "Step 7: Building & Starting IceHRM (source build — takes several minutes)"
cd "$IH_DIR/src" || error "Cannot navigate to $IH_DIR/src"
docker compose -f docker-compose-prod.yaml up -d --build || error "Failed to build/start IceHRM. Check output above."

section "Step 8: Verifying Container"
sleep 12
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^icehrm-app$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs icehrm-app"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for IceHRM to be ready on port 8126..."
HEALTH_OK=0
for i in $(seq 1 12); do
    if curl -s --max-time 5 http://127.0.0.1:8126 &>/dev/null; then
        info "Port 8126 is responding — IceHRM is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 10s..."
    sleep 10
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    warn "IceHRM may still be starting. Check: docker logs icehrm-app"
fi

section "Step 10: Opening Firewall Port 8126"
if command -v ufw &> /dev/null; then
    ufw allow 8126/tcp
    info "UFW: port 8126/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  IceHRM URL:                                   ║"
echo "  ║      http://$SERVER_IP:8126"
echo "  ║                                                      ║"
echo "  ║  🔑  Default login (change immediately!):          ║"
echo "  ║      Username : admin"
echo "  ║      Password : admin"
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
