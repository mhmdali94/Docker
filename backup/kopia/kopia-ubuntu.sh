#!/bin/bash
#
# ============================================================
#   Kopia Auto-Installer
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
echo "  ║         Kopia Auto-Installer                     ║"
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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^kopia$' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing container: kopia"
    docker rm -f kopia 2>/dev/null || true
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
KP_DIR="/root/docker/kopia"
if [ -d "$KP_DIR" ]; then
    warn "Removing old directory $KP_DIR..."
    rm -rf "$KP_DIR"
fi
mkdir -p "$KP_DIR"/{repository,cache}
cd "$KP_DIR" || error "Cannot navigate to $KP_DIR"
info "Directory ready: $KP_DIR"

section "Step 6: Generating Credentials & docker-compose.yml"
KOPIA_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
info "Admin User     : admin"
info "Admin Password : $KOPIA_PASS"
info "Repository Password : $KOPIA_PASS (same for demo)"

cat > "$KP_DIR/docker-compose.yml" <<EOF
services:
  kopia:
    image: kopia/kopia:latest
    container_name: kopia
    restart: unless-stopped
    ports:
      - "51515:51515"
    volumes:
      - ./repository:/repository
      - ./cache:/app/cache
      - /:/data:ro
    entrypoint: ["/bin/sh", "-c"]
    command:
      - "kopia repository connect filesystem --path=/repository --password=$KOPIA_PASS 2>/dev/null || kopia repository create filesystem --path=/repository --password=$KOPIA_PASS && kopia server start --insecure --address=0.0.0.0:51515 --server-username=admin --server-password=$KOPIA_PASS --server-control-username=admin --server-control-password=$KOPIA_PASS"
EOF
info "docker-compose.yml created."

section "Step 7: Starting Kopia"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 8: Verifying Container"
sleep 10
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^kopia$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs kopia"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for Kopia to be ready on port 51515..."
HEALTH_OK=0
for i in $(seq 1 12); do
    if curl -sf --max-time 5 http://127.0.0.1:51515 &>/dev/null; then
        info "Port 51515 is responding — Kopia is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    warn "Kopia may still be starting. Check: docker logs kopia"
fi

section "Step 10: Opening Firewall Port 51515"
if command -v ufw &> /dev/null; then
    ufw allow 51515/tcp
    info "UFW: port 51515/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Kopia in your browser:                 ║"
echo "  ║      👉  http://$SERVER_IP:51515"
echo "  ║                                                      ║"
echo "  ║  🔑  Login Credentials (save these!):              ║"
echo "  ║      Username : admin"
echo "  ║      Password : $KOPIA_PASS"
echo "  ║                                                      ║"
echo "  ║  📦  Repository & password : same as above         ║"
echo "  ║  📁  Host / is mounted read-only at /data         ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
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
