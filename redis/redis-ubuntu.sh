#!/bin/bash
#
# ============================================================
#   Redis Auto-Installer
#   Made by: prismatechwork.com
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
echo "  ║       Redis In-Memory Database Auto-Installer    ║"
echo "  ║       Made by: prismatechwork.com                ║"
echo "  ║                                                  ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️         ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""

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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^redis$' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing Redis containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
REDIS_DIR="/root/docker/redis"
if [ -d "$REDIS_DIR" ]; then
    warn "Removing old directory $REDIS_DIR..."
    rm -rf "$REDIS_DIR"
fi
mkdir -p "$REDIS_DIR"
cd "$REDIS_DIR" || error "Cannot navigate to $REDIS_DIR"
info "Directory ready: $REDIS_DIR"

section "Step 6: Generating Credentials & docker-compose.yml"
REDIS_PASSWORD=$(tr -dc 'A-Za-z0-9!@#$%' < /dev/urandom | head -c 24)
info "Redis password generated."

cat > "$REDIS_DIR/docker-compose.yml" <<EOF
services:
  redis:
    image: redis:latest
    container_name: redis
    restart: unless-stopped
    ports:
      - "6379:6379"
    volumes:
      - ./data:/data
    command: redis-server --appendonly yes --requirepass $REDIS_PASSWORD
EOF
info "docker-compose.yml created."

section "Step 7: Starting Redis"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 8: Verifying Container"
sleep 4
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^redis$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs redis"
else
    info "Container running: $RUNNING"
fi

SERVER_IP=$(hostname -I | awk '{print $1}')
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🗄️  Redis is running on port 6379                  ║"
echo "  ║      Host: $SERVER_IP"
echo "  ║      Port: 6379"
echo "  ║                                                      ║"
echo "  ║  🔑  Connection Password (save this!):              ║"
echo "  ║      $REDIS_PASSWORD"
echo "  ║                                                      ║"
echo "  ║  Connect with: redis-cli -h $SERVER_IP -p 6379 -a <password>"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: prismatechwork.com                   ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
