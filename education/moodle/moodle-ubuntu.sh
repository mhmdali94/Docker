#!/bin/bash
# ============================================================
#   Moodle Auto-Installer
#   Made by: Mohammed Ali Elshikh | prismatechwork.com
#   ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️
# ============================================================
set -e
G="\e[32m"; Y="\e[33m"; R="\e[31m"; C="\e[36m"; B="\e[1m"; RST="\e[0m"
info()    { echo -e "${G}[INFO]${RST} $*"; }
warn()    { echo -e "${Y}[WARN]${RST} $*"; }
error()   { echo -e "${R}[ERROR]${RST} $*"; exit 1; }
section() { echo -e "\n${C}${B}══════════════════════ $* ══════════════════════${RST}"; }

clear
echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║     Moodle Auto-Installer                       ║"
echo "  ║     Made by: Mohammed Ali Elshikh              ║"
echo "  ║     prismatechwork.com                         ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️        ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""
echo "  Press ENTER to continue ... Ctrl+C to cancel."
read -rp "" _

section "Step 0: Checking Privileges"
[ "$EUID" -ne 0 ] && error "Please run as root: sudo bash $0"
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

section "Step 4: Configuration"
DB_PASS=$(openssl rand -hex 16)
ADMIN_PASS=$(openssl rand -base64 12 | tr -d '=+/')
read -rp "  Admin username [moodleadmin]: " ADMIN_USER
ADMIN_USER="${ADMIN_USER:-moodleadmin}"
read -rp "  Admin email [admin@moodle.local]: " ADMIN_EMAIL
ADMIN_EMAIL="${ADMIN_EMAIL:-admin@moodle.local}"
SERVER_IP_DEFAULT=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
read -rp "  Enter your server IP or domain [$SERVER_IP_DEFAULT]: " SERVER_ADDR
SERVER_ADDR="${SERVER_ADDR:-$SERVER_IP_DEFAULT}"
info "Admin: $ADMIN_USER | Server: $SERVER_ADDR"

section "Step 5: Cleaning Up Existing Containers"
for cname in moodle moodle-mariadb; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    [ -n "$EXISTING" ] && warn "Removing $cname..." && docker rm -f "$cname" 2>/dev/null || true
done

section "Step 6: Preparing Directory"
APP_DIR="/root/docker/moodle"
mkdir -p "$APP_DIR/moodledata"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 7: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  moodle:
    image: bitnamilegacy/moodle:latest
    container_name: moodle
    restart: unless-stopped
    ports:
      - "8083:8080"
    environment:
      MOODLE_DATABASE_HOST: moodle-mariadb
      MOODLE_DATABASE_PORT_NUMBER: 3306
      MOODLE_DATABASE_NAME: moodle
      MOODLE_DATABASE_USER: moodle
      MOODLE_DATABASE_PASSWORD: ${DB_PASS}
      MOODLE_USERNAME: ${ADMIN_USER}
      MOODLE_PASSWORD: ${ADMIN_PASS}
      MOODLE_EMAIL: ${ADMIN_EMAIL}
      MOODLE_SITE_NAME: My Moodle
      MOODLE_HOST: ${SERVER_ADDR}
      BITNAMI_DEBUG: "false"
    volumes:
      - ./moodledata:/bitnami/moodle
      - ./moodledata-vol:/bitnami/moodledata
    depends_on:
      - moodle-mariadb

  moodle-mariadb:
    image: bitnamilegacy/mariadb:10.11
    container_name: moodle-mariadb
    restart: unless-stopped
    environment:
      MARIADB_ROOT_PASSWORD: ${DB_PASS}
      MARIADB_DATABASE: moodle
      MARIADB_USER: moodle
      MARIADB_PASSWORD: ${DB_PASS}
      MARIADB_CHARACTER_SET: utf8mb4
      MARIADB_COLLATE: utf8mb4_unicode_ci
    volumes:
      - ./mariadb:/bitnami/mariadb
EOF
info "docker-compose.yml created."

section "Step 8: Starting Moodle (~3 min for first install)"
warn "Moodle first install takes 3-5 minutes — please wait."
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start."
else
    docker-compose up -d || error "Failed to start."
fi

section "Step 9: Health Check"
info "Waiting for Moodle to be ready..."
for i in $(seq 1 36); do
    if curl -s --max-time 5 http://127.0.0.1:8083 &>/dev/null; then
        info "Moodle is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/36 — waiting 10s..."
    sleep 10
    echo " retrying"
done

section "Step 10: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 8083/tcp
    info "UFW: port 8083 opened."
else
    warn "UFW not found — skipping."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🎓  Moodle LMS:                                   ║"
echo "  ║      👉  http://$SERVER_ADDR:8083"
echo "  ║                                                      ║"
echo "  ║  🔑  Admin credentials:                            ║"
printf  "  ║      Username: %-38s║\n" "$ADMIN_USER"
printf  "  ║      Password: %-38s║\n" "$ADMIN_PASS"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║                                                      ║"
echo "  ║  🚀  Need production setup?                         ║"
echo "  ║      👨‍💻  Mohammed Ali Elshikh                      ║"
echo "  ║      🌐  prismatechwork.com                         ║"
echo "  ║                                                      ║"
echo "  ║  ☕  Support this script — USDT (TRC-20 only):     ║"
echo "  ║      TCSZTkXvhibdrFre5sdTsFLRQ6d6yQkd2i           ║"
echo "  ║                                                      ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
