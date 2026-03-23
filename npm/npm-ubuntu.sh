#!/bin/bash
#
# ============================================================
#   Nginx Proxy Manager (NPM) Auto-Installer
#   Made by: prismatechwork.com
#
#   ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️
#   This script is NOT intended for production use.
#   Use it only in lab or testing environments.
# ============================================================

set -e  # Exit on error

# ------------------------------------
# Helper functions
# ------------------------------------
info()    { echo -e "\e[32m[INFO]\e[0m $*"; }
warn()    { echo -e "\e[33m[WARN]\e[0m $*"; }
error()   { echo -e "\e[31m[ERROR]\e[0m $*"; exit 1; }
section() { echo -e "\n\e[36m========== $* ==========\e[0m"; }

# ------------------------------------
# Banner
# ------------------------------------
clear
echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║    Nginx Proxy Manager (NPM) Auto-Installer      ║"
echo "  ║    Made by: prismatechwork.com                   ║"
echo "  ║                                                  ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️         ║"
echo "  ║     Not intended for production use.             ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""

# ------------------------------------
# Step 0: Root check
# ------------------------------------
section "Step 0: Checking Privileges"
if [ "$EUID" -ne 0 ]; then
    error "Please run this script as root: sudo bash $0"
fi
info "Running as root. OK."

# ------------------------------------
# Step 1: OS Verification
# ------------------------------------
section "Step 1: Verifying Operating System"
if [ ! -f /etc/os-release ]; then
    error "Cannot determine OS. Only Ubuntu 22.04 and 24.04 are supported."
fi

. /etc/os-release

if [ "$ID" != "ubuntu" ]; then
    error "Unsupported OS: $ID. Only Ubuntu is supported."
fi

if [ "$VERSION_ID" != "22.04" ] && [ "$VERSION_ID" != "24.04" ]; then
    error "Unsupported Ubuntu version: $VERSION_ID. Only 22.04 and 24.04 are supported."
fi

info "OS check passed: Ubuntu $VERSION_ID"

# ------------------------------------
# Step 2: Ensure Docker is installed
# ------------------------------------
section "Step 2: Checking Docker"
if ! command -v docker &> /dev/null; then
    warn "Docker is not installed. Installing Docker..."
    apt update -y
    apt install -y docker.io
    systemctl enable --now docker
    info "Docker installed successfully."
else
    info "Docker is already installed: $(docker --version)"
fi

# ------------------------------------
# Step 3: Ensure Docker Compose V2
# ------------------------------------
section "Step 3: Checking Docker Compose V2"
if ! docker compose version &> /dev/null; then
    warn "Docker Compose V2 not found. Installing..."
    apt update -y
    apt install -y docker-compose-v2 || apt install -y docker-compose
    info "Docker Compose installed."
else
    info "Docker Compose V2 is already installed: $(docker compose version)"
fi

# ------------------------------------
# Step 4: Stop & Remove existing containers
# ------------------------------------
section "Step 4: Cleaning Up Existing NPM Containers"

EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E 'nginx-proxy-manager|npm[-_]app|npm[-_]db|npm_app|npm_db' || true)

if [ -n "$EXISTING" ]; then
    warn "Found existing NPM containers. Stopping and removing..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
    info "Containers removed."
else
    info "No existing NPM containers found."
fi

# Prune any dangling networks
docker network prune -f &>/dev/null || true

# ------------------------------------
# Step 5: Clean existing directory
# ------------------------------------
section "Step 5: Preparing Installation Directory"
NPM_DIR="/root/docker/npm"

if [ -d "$NPM_DIR" ]; then
    warn "Existing directory found at $NPM_DIR. Removing..."
    rm -rf "$NPM_DIR"
fi

mkdir -p "$NPM_DIR"
cd "$NPM_DIR" || error "Failed to navigate to $NPM_DIR"
info "Directory ready: $NPM_DIR"

# ------------------------------------
# Step 6: Generate secure DB password
# ------------------------------------
section "Step 6: Generating Database Credentials"
DB_USER="npm"
DB_NAME="npm"
DB_PASSWORD=$(tr -dc 'A-Za-z0-9!@#$%' < /dev/urandom | head -c 20)
DB_ROOT_PASSWORD=$(tr -dc 'A-Za-z0-9!@#$%' < /dev/urandom | head -c 20)

info "Database user    : $DB_USER"
info "Database name    : $DB_NAME"
info "Database password: $DB_PASSWORD"

# ------------------------------------
# Step 7: Generate config.json
# ------------------------------------
section "Step 7: Generating config.json"

cat > "$NPM_DIR/config.json" <<EOF
{
  "database": {
    "engine": "mysql",
    "host": "db",
    "name": "$DB_NAME",
    "user": "$DB_USER",
    "password": "$DB_PASSWORD",
    "port": 3306
  }
}
EOF

info "config.json created at $NPM_DIR/config.json"

# ------------------------------------
# Step 8: Generate docker-compose.yml
# ------------------------------------
section "Step 8: Generating docker-compose.yml"

cat > "$NPM_DIR/docker-compose.yml" <<EOF
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    container_name: npm_app
    restart: unless-stopped
    ports:
      - '80:80'
      - '81:81'
      - '443:443'
    volumes:
      - ./config.json:/app/config/production.json
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
    depends_on:
      - db

  db:
    image: 'jc21/mariadb-aria:latest'
    container_name: npm_db
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: '$DB_ROOT_PASSWORD'
      MYSQL_DATABASE: '$DB_NAME'
      MYSQL_USER: '$DB_USER'
      MYSQL_PASSWORD: '$DB_PASSWORD'
    volumes:
      - ./data/mysql:/var/lib/mysql
EOF

info "docker-compose.yml created at $NPM_DIR/docker-compose.yml"

# ------------------------------------
# Step 9: Start containers
# ------------------------------------
section "Step 9: Starting NPM Containers"

if docker compose version &> /dev/null; then
    docker compose up -d
elif command -v docker-compose &> /dev/null; then
    docker-compose up -d
else
    error "Docker Compose not found. Cannot start containers."
fi

# ------------------------------------
# Step 10: Verify containers are running
# ------------------------------------
section "Step 10: Verifying Containers"
sleep 5

RUNNING=$(docker ps --format '{{.Names}}' | grep -E 'npm_app|npm_db' || true)
if [ -z "$RUNNING" ]; then
    warn "Containers may not have started correctly. Check logs:"
    echo "  docker logs npm_app"
    echo "  docker logs npm_db"
else
    info "Containers running: $RUNNING"
fi

# ------------------------------------
# Done
# ------------------------------------
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ║                                                      ║"
echo "  ║  Admin Panel  : http://$(hostname -I | awk '{print $1}'):81"
echo "  ║  Directory    : $NPM_DIR"
echo "  ║                                                      ║"
echo "  ║  🔑 Default Login Credentials:                      ║"
echo "  ║     Email    : admin@example.com                    ║"
echo "  ║     Password : changeme                             ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  Change credentials immediately after login!    ║"
echo "  ║                                                      ║"
echo "  ║  🗄️  Database Credentials (save these!):            ║"
echo "  ║     DB User     : $DB_USER"
echo "  ║     DB Name     : $DB_NAME"
echo "  ║     DB Password : $DB_PASSWORD"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: prismatechwork.com                   ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
