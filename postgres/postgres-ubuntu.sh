#!/bin/bash
#
# ============================================================
#   PostgreSQL Auto-Installer
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
echo "  ║       PostgreSQL Database Auto-Installer         ║"
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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^postgres$' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing PostgreSQL containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
PG_DIR="/root/docker/postgres"
if [ -d "$PG_DIR" ]; then
    warn "Removing old directory $PG_DIR..."
    rm -rf "$PG_DIR"
fi
mkdir -p "$PG_DIR"
cd "$PG_DIR" || error "Cannot navigate to $PG_DIR"
info "Directory ready: $PG_DIR"

section "Step 6: Generating Credentials & docker-compose.yml"
PG_USER="pgadmin"
PG_DB="pgdb"
PG_PASSWORD=$(tr -dc 'A-Za-z0-9!@#$%' < /dev/urandom | head -c 24)
info "DB User     : $PG_USER"
info "DB Name     : $PG_DB"
info "DB Password : $PG_PASSWORD"

cat > "$PG_DIR/docker-compose.yml" <<EOF
services:
  postgres:
    image: postgres:latest
    container_name: postgres
    restart: unless-stopped
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: $PG_USER
      POSTGRES_PASSWORD: $PG_PASSWORD
      POSTGRES_DB: $PG_DB
    volumes:
      - ./data:/var/lib/postgresql/data
EOF
info "docker-compose.yml created."

section "Step 7: Starting PostgreSQL"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 8: Verifying Container"
sleep 5
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^postgres$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs postgres"
else
    info "Container running: $RUNNING"
fi

SERVER_IP=$(hostname -I | awk '{print $1}')
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🗄️  PostgreSQL is running on port 5432             ║"
echo "  ║                                                      ║"
echo "  ║  🔑  Connection Details (save these!):              ║"
echo "  ║      Host     : $SERVER_IP"
echo "  ║      Port     : 5432"
echo "  ║      User     : $PG_USER"
echo "  ║      Password : $PG_PASSWORD"
echo "  ║      Database : $PG_DB"
echo "  ║                                                      ║"
echo "  ║  Connect: psql -h $SERVER_IP -U $PG_USER -d $PG_DB"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: prismatechwork.com                   ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
