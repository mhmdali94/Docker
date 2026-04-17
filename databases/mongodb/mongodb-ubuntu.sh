#!/bin/bash
#
# ============================================================
#   MongoDB Auto-Installer
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
echo "  ║       MongoDB Auto-Installer                     ║"
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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^mongodb$' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing MongoDB containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
MONGO_DIR="/root/docker/mongodb"
if [ -d "$MONGO_DIR" ]; then
    warn "Removing old directory $MONGO_DIR..."
    rm -rf "$MONGO_DIR"
fi
mkdir -p "$MONGO_DIR"
cd "$MONGO_DIR" || error "Cannot navigate to $MONGO_DIR"
info "Directory ready: $MONGO_DIR"

section "Step 6: Generating Credentials & docker-compose.yml"
MONGO_USER="mongoadmin"
MONGO_PASSWORD=$(tr -dc 'A-Za-z0-9!@#$%' < /dev/urandom | head -c 24)
info "Mongo User     : $MONGO_USER"
info "Mongo Password : $MONGO_PASSWORD"

cat > "$MONGO_DIR/docker-compose.yml" <<EOF
services:
  mongodb:
    image: mongo:latest
    container_name: mongodb
    restart: unless-stopped
    ports:
      - "27017:27017"
    environment:
      MONGO_INITDB_ROOT_USERNAME: $MONGO_USER
      MONGO_INITDB_ROOT_PASSWORD: $MONGO_PASSWORD
    volumes:
      - ./data:/data/db
EOF
info "docker-compose.yml created."

section "Step 7: Starting MongoDB"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 8: Verifying Container"
sleep 5
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^mongodb$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs mongodb"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for MongoDB to be ready on port 27017..."
HEALTH_OK=0
for i in $(seq 1 12); do
    if docker exec mongodb mongosh --quiet --eval "db.runCommand('ping').ok" 2>/dev/null | grep -q "1"; then
        info "MongoDB is ready and accepting connections. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 27017 2>/dev/null; then
        warn "Port 27017 is open but ping timed out. Service may still be starting."
        warn "Check logs: docker logs mongodb"
    else
        warn "Port 27017 is NOT responding after 60s."
        warn "Check logs: docker logs mongodb"
        docker logs --tail 20 mongodb 2>&1 || true
    fi
fi

section "Step 10: Opening Firewall Port 27017"
if command -v ufw &> /dev/null; then
    ufw allow 27017/tcp
    info "UFW: port 27017/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🗄️  MongoDB is running on port 27017              ║"
echo "  ║                                                      ║"
echo "  ║  🔑  Connection Details (save these!):              ║"
echo "  ║      Host     : $SERVER_IP"
echo "  ║      Port     : 27017"
echo "  ║      User     : $MONGO_USER"
echo "  ║      Password : $MONGO_PASSWORD"
echo "  ║                                                      ║"
echo "  ║  URI: mongodb://$MONGO_USER:$MONGO_PASSWORD@$SERVER_IP:27017"
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
