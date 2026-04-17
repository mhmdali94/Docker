#!/bin/bash
#
# ============================================================
#   MariaDB Auto-Installer
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
echo "  ║       MariaDB Database Auto-Installer            ║"
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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^mariadb$' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing MariaDB containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
MARIADB_DIR="/root/docker/mariadb"
if [ -d "$MARIADB_DIR" ]; then
    warn "Removing old directory $MARIADB_DIR..."
    rm -rf "$MARIADB_DIR"
fi
mkdir -p "$MARIADB_DIR"
cd "$MARIADB_DIR" || error "Cannot navigate to $MARIADB_DIR"
info "Directory ready: $MARIADB_DIR"

section "Step 6: Generating Credentials & docker-compose.yml"
DB_USER="dbadmin"
DB_NAME="appdb"
DB_PASSWORD=$(tr -dc 'A-Za-z0-9!@#$%' < /dev/urandom | head -c 24)
DB_ROOT_PASSWORD=$(tr -dc 'A-Za-z0-9!@#$%' < /dev/urandom | head -c 24)
info "DB User          : $DB_USER"
info "DB Name          : $DB_NAME"
info "DB Password      : $DB_PASSWORD"
info "DB Root Password : $DB_ROOT_PASSWORD"

cat > "$MARIADB_DIR/docker-compose.yml" <<EOF
services:
  mariadb:
    image: mariadb:latest
    container_name: mariadb
    restart: unless-stopped
    ports:
      - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: $DB_ROOT_PASSWORD
      MYSQL_DATABASE: $DB_NAME
      MYSQL_USER: $DB_USER
      MYSQL_PASSWORD: $DB_PASSWORD
    volumes:
      - ./data:/var/lib/mysql
EOF
info "docker-compose.yml created."

section "Step 7: Starting MariaDB"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 8: Verifying Container"
sleep 5
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^mariadb$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs mariadb"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for MariaDB to be ready on port 3306..."
HEALTH_OK=0
for i in $(seq 1 12); do
    if docker exec mariadb mysqladmin ping -h 127.0.0.1 --silent 2>/dev/null; then
        info "MariaDB is ready and accepting connections. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 3306 2>/dev/null; then
        warn "Port 3306 is open but mysqladmin ping timed out. Service may still be starting."
        warn "Check logs: docker logs mariadb"
    else
        warn "Port 3306 is NOT responding after 60s."
        warn "Check logs: docker logs mariadb"
        docker logs --tail 20 mariadb 2>&1 || true
    fi
fi

section "Step 10: Opening Firewall Port 3306"
if command -v ufw &> /dev/null; then
    ufw allow 3306/tcp
    info "UFW: port 3306/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🗄️  MariaDB is running on port 3306               ║"
echo "  ║                                                      ║"
echo "  ║  🔑  Connection Details (save these!):              ║"
echo "  ║      Host          : $SERVER_IP"
echo "  ║      Port          : 3306"
echo "  ║      User          : $DB_USER"
echo "  ║      Password      : $DB_PASSWORD"
echo "  ║      Database      : $DB_NAME"
echo "  ║      Root Password : $DB_ROOT_PASSWORD"
echo "  ║                                                      ║"
echo "  ║  Connect: mysql -h $SERVER_IP -u $DB_USER -p $DB_NAME"
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
