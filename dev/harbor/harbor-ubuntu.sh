#!/bin/bash
#
# ============================================================
#   Harbor Container Registry Auto-Installer
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
echo "  ║       Harbor Container Registry Auto-Installer   ║"
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

section "Step 4: Checking Dependencies"
apt update -y && apt install -y curl wget openssl
info "Dependencies OK."

section "Step 5: Preparing Directory"
HARBOR_DIR="/root/docker/harbor"
if [ -d "$HARBOR_DIR" ]; then
    warn "Removing old directory $HARBOR_DIR..."
    rm -rf "$HARBOR_DIR"
fi
mkdir -p "$HARBOR_DIR"
cd "$HARBOR_DIR" || error "Cannot navigate to $HARBOR_DIR"
info "Directory ready: $HARBOR_DIR"

section "Step 6: Downloading Harbor Offline Installer"
HARBOR_VERSION="v2.11.0"
HARBOR_TGZ="harbor-offline-installer-${HARBOR_VERSION}.tgz"
HARBOR_URL="https://github.com/goharbor/harbor/releases/download/${HARBOR_VERSION}/${HARBOR_TGZ}"
info "Downloading Harbor ${HARBOR_VERSION}..."
wget -q --show-progress "$HARBOR_URL" -O "$HARBOR_DIR/$HARBOR_TGZ" || error "Failed to download Harbor. Check your internet connection."
tar xzf "$HARBOR_DIR/$HARBOR_TGZ" -C "$HARBOR_DIR" --strip-components=1
info "Harbor extracted."

section "Step 7: Generating Credentials & harbor.yml"
SERVER_IP_SETUP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
HARBOR_ADMIN_PASS=$(tr -dc 'A-Za-z0-9!@#$%' < /dev/urandom | head -c 20)
info "Admin User     : admin"
info "Admin Password : $HARBOR_ADMIN_PASS"

cp "$HARBOR_DIR/harbor.yml.tmpl" "$HARBOR_DIR/harbor.yml"
sed -i "s|^hostname:.*|hostname: $SERVER_IP_SETUP|" "$HARBOR_DIR/harbor.yml"
sed -i "s|^  port: 443|  port: 8444|" "$HARBOR_DIR/harbor.yml"
sed -i '/^https:/,/^[^ ]/{s/^/#/}' "$HARBOR_DIR/harbor.yml" || true
sed -i "s|harbor_admin_password:.*|harbor_admin_password: $HARBOR_ADMIN_PASS|" "$HARBOR_DIR/harbor.yml"
sed -i "s|^http:|http:|" "$HARBOR_DIR/harbor.yml"
sed -i "s|^  port: 80$|  port: 5080|" "$HARBOR_DIR/harbor.yml"
info "harbor.yml configured."

section "Step 8: Running Harbor Installer"
cd "$HARBOR_DIR" && bash install.sh
info "Harbor installer completed."

section "Step 9: Verifying Containers"
sleep 10
RUNNING=$(docker ps --format '{{.Names}}' | grep -E 'harbor' || true)
if [ -z "$RUNNING" ]; then
    warn "Containers may not have started. Check: docker logs harbor-core"
else
    info "Containers running: $RUNNING"
fi

section "Step 10: Health Check"
info "Waiting for Harbor to be ready on port 5080 (may take a few minutes)..."
HEALTH_OK=0
for i in $(seq 1 24); do
    if curl -sf --max-time 5 http://127.0.0.1:5080 &>/dev/null; then
        info "Port 5080 is responding — Harbor is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/24 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 5080 2>/dev/null; then
        warn "Port 5080 is open but HTTP did not respond. Still initializing."
        warn "Check logs: docker logs harbor-core"
    else
        warn "Port 5080 is NOT responding after 120s."
        warn "Check logs: docker logs harbor-core"
        docker logs --tail 20 harbor-core 2>&1 || true
    fi
fi

section "Step 11: Opening Firewall Port 5080"
if command -v ufw &> /dev/null; then
    ufw allow 5080/tcp
    info "UFW: port 5080/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Harbor in your browser:                  ║"
echo "  ║      👉  http://$SERVER_IP:5080"
echo "  ║                                                      ║"
echo "  ║  🔑  Login Credentials (save these!):              ║"
echo "  ║      Username : admin"
echo "  ║      Password : $HARBOR_ADMIN_PASS"
echo "  ║                                                      ║"
echo "  ║  🐳  Docker login:                                  ║"
echo "  ║      docker login $SERVER_IP:5080"
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
