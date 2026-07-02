#!/bin/bash
#
# ============================================================
#   Remotely Auto-Installer
#   Made by: Mohammed Ali Elshikh | prismatechwork.com
#
#   ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️
#   This script is NOT intended for production use.
#
#   NOTE: Remotely by Immense Networks was discontinued in 2023.
#   This installs the last stable Docker release.
#   Consider migrating to RustDesk or MeshCentral for new setups.
# ============================================================

set -e

info()    { echo -e "\e[32m[INFO]\e[0m $*"; }
warn()    { echo -e "\e[33m[WARN]\e[0m $*"; }
error()   { echo -e "\e[31m[ERROR]\e[0m $*"; exit 1; }
section() { echo -e "\n\e[36m========== $* ==========\e[0m"; }

clear
echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║       Remotely Auto-Installer                    ║"
echo "  ║       Made by: Mohammed Ali Elshikh             ║"
echo "  ║       prismatechwork.com                        ║"
echo "  ║                                                  ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️         ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║  ⚠️   DEMO / TESTING USE ONLY                        ║"
echo "  ║                                                      ║"
echo "  ║  NOTE: Remotely was discontinued in 2023.           ║"
echo "  ║  This installs the last stable Docker release.      ║"
echo "  ║                                                      ║"
echo "  ║  Press ENTER to continue... Ctrl+C to cancel.       ║"
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
if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -qE '^remotely$'; then
    warn "Removing existing container: remotely"
    docker rm -f remotely 2>/dev/null || true
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
RL_DIR="/root/docker/remotely"
if [ -d "$RL_DIR" ]; then
    warn "Removing old directory $RL_DIR..."
    rm -rf "$RL_DIR"
fi
mkdir -p "$RL_DIR/data"
cd "$RL_DIR" || error "Cannot navigate to $RL_DIR"
info "Directory ready: $RL_DIR"

section "Step 6: Creating docker-compose.yml"
warn "Checking if Remotely image is still available..."
if ! docker pull immensegroups/remotely:latest &>/dev/null; then
    warn "======================================================"
    warn "Remotely (immensegroups/remotely) image not found."
    warn "The project was discontinued in 2023 and the image"
    warn "has been removed from Docker Hub."
    warn "Consider RustDesk (rustdesk-ubuntu.sh) instead."
    warn "======================================================"
    error "Cannot install: Docker image unavailable."
fi

cat > "$RL_DIR/docker-compose.yml" <<EOF
services:
  remotely:
    image: immybot/remotely:latest
    container_name: remotely
    restart: unless-stopped
    ports:
      - "5000:5000"
    volumes:
      - ./data:/remotely-data
EOF
info "docker-compose.yml created."

section "Step 7: Starting Remotely"
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    docker compose up -d && break
    warn "Docker pull failed on attempt $attempt/$MAX_RETRIES."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed to start after $MAX_RETRIES attempts."
done

section "Step 8: Verifying Container"
sleep 10
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^remotely$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs remotely"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for Remotely to be ready on port 5000..."
HEALTH_OK=0
for i in $(seq 1 12); do
    if curl -s --max-time 5 http://127.0.0.1:5000 &>/dev/null; then
        info "Port 5000 is responding — Remotely is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done
[ "$HEALTH_OK" -eq 0 ] && warn "Remotely may still be initializing. Check: docker logs remotely"

section "Step 10: Opening Firewall Port 5000"
if command -v ufw &> /dev/null; then
    ufw allow 5000/tcp
    info "UFW: port 5000/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Remotely in your browser:                ║"
echo "  ║      👉  http://$SERVER_IP:5000                     ║"
echo "  ║                                                      ║"
echo "  ║  🔑  Register an admin account on first visit.     ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  PROJECT DISCONTINUED — no security updates.   ║"
echo "  ║       Consider RustDesk for new deployments.        ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║  🚀  Need production setup?                         ║"
echo "  ║      👨‍💻  Mohammed Ali Elshikh | prismatechwork.com  ║"
echo "  ║  ☕  USDT TRC-20: TCSZTkXvhibdrFre5sdTsFLRQ6d6yQkd2i ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
