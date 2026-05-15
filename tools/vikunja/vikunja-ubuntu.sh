#!/bin/bash
#
# ============================================================
#   Vikunja Auto-Installer
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
echo "  ║         Vikunja Auto-Installer                   ║"
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
for cname in vikunja vikunja-db; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    if [ -n "$EXISTING" ]; then
        warn "Removing existing container: $cname"
        docker rm -f "$cname" 2>/dev/null || true
    fi
done
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
VK_DIR="/root/docker/vikunja"
if [ -d "$VK_DIR" ]; then
    warn "Removing old directory $VK_DIR..."
    rm -rf "$VK_DIR"
fi
mkdir -p "$VK_DIR/files"
cd "$VK_DIR" || error "Cannot navigate to $VK_DIR"
info "Directory ready: $VK_DIR"

section "Step 6: Generating Credentials & docker-compose.yml"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
ROOT_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
JWT_SECRET=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)
info "Register your account on first visit at http://$SERVER_IP:3456"

cat > "$VK_DIR/docker-compose.yml" <<EOF
services:
  vikunja-db:
    image: mariadb:10.11
    container_name: vikunja-db
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: $ROOT_PASS
      MYSQL_DATABASE: vikunja
      MYSQL_USER: vikunja
      MYSQL_PASSWORD: $DB_PASS
    volumes:
      - ./mysql:/var/lib/mysql

  vikunja:
    image: vikunja/vikunja:latest
    container_name: vikunja
    restart: unless-stopped
    ports:
      - "3456:3456"
    environment:
      VIKUNJA_DATABASE_TYPE: mysql
      VIKUNJA_DATABASE_HOST: vikunja-db
      VIKUNJA_DATABASE_DATABASE: vikunja
      VIKUNJA_DATABASE_USER: vikunja
      VIKUNJA_DATABASE_PASSWORD: $DB_PASS
      VIKUNJA_SERVICE_JWTSECRET: $JWT_SECRET
      VIKUNJA_SERVICE_FRONTENDURL: http://$SERVER_IP:3456/
    volumes:
      - ./files:/app/vikunja/files
    depends_on:
      - vikunja-db
EOF
info "docker-compose.yml created."

section "Step 7: Starting Vikunja"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 8: Verifying Container"
sleep 15
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^vikunja$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs vikunja"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for Vikunja to be ready on port 3456..."
HEALTH_OK=0
for i in $(seq 1 12); do
    if curl -sf --max-time 5 http://127.0.0.1:3456 &>/dev/null; then
        info "Port 3456 is responding — Vikunja is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 10s..."
    sleep 10
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    warn "Vikunja may still be initializing. Check: docker logs vikunja"
fi

section "Step 10: Opening Firewall Port 3456"
if command -v ufw &> /dev/null; then
    ufw allow 3456/tcp
    info "UFW: port 3456/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Vikunja in your browser:               ║"
echo "  ║      👉  http://$SERVER_IP:3456"
echo "  ║                                                      ║"
echo "  ║  🔑  Register your account on first visit.         ║"
echo "  ║      First registered user becomes admin.          ║"
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
