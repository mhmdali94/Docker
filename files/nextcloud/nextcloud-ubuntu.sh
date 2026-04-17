#!/bin/bash
#
# ============================================================
#   Nextcloud Self-Hosted Cloud Auto-Installer
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
echo "  ║       Nextcloud Self-Hosted Cloud Installer      ║"
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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^nextcloud' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing Nextcloud containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
NC_DIR="/root/docker/nextcloud"
if [ -d "$NC_DIR" ]; then
    warn "Removing old directory $NC_DIR..."
    rm -rf "$NC_DIR"
fi
mkdir -p "$NC_DIR"
cd "$NC_DIR" || error "Cannot navigate to $NC_DIR"
info "Directory ready: $NC_DIR"

section "Step 6: Generating Credentials & docker-compose.yml"
NC_DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 24)
NC_ADMIN_PASS=$(tr -dc 'A-Za-z0-9!@#$%' < /dev/urandom | head -c 20)
info "Admin User     : admin"
info "Admin Password : $NC_ADMIN_PASS"

cat > "$NC_DIR/docker-compose.yml" <<EOF
services:
  nextcloud-db:
    image: mariadb:10.11
    container_name: nextcloud-db
    restart: unless-stopped
    command: --transaction-isolation=READ-COMMITTED --binlog-format=ROW
    environment:
      MYSQL_ROOT_PASSWORD: $NC_DB_PASS
      MYSQL_DATABASE: nextcloud
      MYSQL_USER: nextcloud
      MYSQL_PASSWORD: $NC_DB_PASS
    volumes:
      - ./db:/var/lib/mysql
    networks:
      - nextcloud-net

  nextcloud:
    image: nextcloud:latest
    container_name: nextcloud
    restart: unless-stopped
    depends_on:
      - nextcloud-db
    ports:
      - "8080:80"
    environment:
      MYSQL_HOST: nextcloud-db
      MYSQL_DATABASE: nextcloud
      MYSQL_USER: nextcloud
      MYSQL_PASSWORD: $NC_DB_PASS
      NEXTCLOUD_ADMIN_USER: admin
      NEXTCLOUD_ADMIN_PASSWORD: $NC_ADMIN_PASS
    volumes:
      - ./data:/var/www/html
    networks:
      - nextcloud-net

networks:
  nextcloud-net:
    driver: bridge
EOF
info "docker-compose.yml created."

section "Step 7: Starting Nextcloud"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 8: Verifying Containers"
sleep 8
RUNNING=$(docker ps --format '{{.Names}}' | grep -E 'nextcloud' || true)
if [ -z "$RUNNING" ]; then
    warn "Containers may not have started. Check: docker logs nextcloud"
else
    info "Containers running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for Nextcloud to be ready on port 8080 (may take up to 2 minutes)..."
HEALTH_OK=0
for i in $(seq 1 24); do
    if curl -sf --max-time 5 http://127.0.0.1:8080/status.php &>/dev/null; then
        info "Port 8080 is responding — Nextcloud is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/24 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 8080 2>/dev/null; then
        warn "Port 8080 is open but /status.php did not respond. Still initializing."
        warn "Check logs: docker logs nextcloud"
    else
        warn "Port 8080 is NOT responding after 120s."
        warn "Check logs: docker logs nextcloud"
        docker logs --tail 20 nextcloud 2>&1 || true
    fi
fi

section "Step 10: Opening Firewall Port 8080"
if command -v ufw &> /dev/null; then
    ufw allow 8080/tcp
    info "UFW: port 8080/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Nextcloud in your browser:               ║"
echo "  ║      👉  http://$SERVER_IP:8080"
echo "  ║                                                      ║"
echo "  ║  🔑  Login Credentials (save these!):              ║"
echo "  ║      Username : admin"
echo "  ║      Password : $NC_ADMIN_PASS"
echo "  ║                                                      ║"
echo "  ║  📦  Features: Files, Calendar, Contacts,          ║"
echo "  ║      Talk, Notes, Office, Photos & 300+ apps       ║"
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
