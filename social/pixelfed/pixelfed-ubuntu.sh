#!/bin/bash
# ============================================================
#   Pixelfed Auto-Installer
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
echo "  ║     Pixelfed Auto-Installer                     ║"
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
echo ""
echo "  ⚠️  Pixelfed REQUIRES a real domain name for federation."
echo ""
read -rp "  Enter your domain (e.g. photos.example.com): " APP_DOMAIN
[ -z "$APP_DOMAIN" ] && error "Domain is required."
DB_PASS=$(openssl rand -hex 16)
APP_KEY="base64:$(openssl rand -base64 32)"
info "Domain: $APP_DOMAIN"

section "Step 5: Cleaning Up Existing Containers"
for cname in pixelfed pixelfed-mysql pixelfed-redis; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    [ -n "$EXISTING" ] && warn "Removing $cname..." && docker rm -f "$cname" 2>/dev/null || true
done

section "Step 6: Preparing Directory"
APP_DIR="/root/docker/pixelfed"
mkdir -p "$APP_DIR/storage"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 7: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  pixelfed:
    image: zknt/pixelfed:latest
    container_name: pixelfed
    restart: unless-stopped
    ports:
      - "8085:80"
    environment:
      APP_NAME: Pixelfed
      APP_ENV: production
      APP_KEY: ${APP_KEY}
      APP_DEBUG: "false"
      APP_URL: http://${APP_DOMAIN}:8085
      APP_DOMAIN: ${APP_DOMAIN}
      ADMIN_DOMAIN: ${APP_DOMAIN}
      SESSION_DOMAIN: ${APP_DOMAIN}
      DB_CONNECTION: mysql
      DB_HOST: pixelfed-mysql
      DB_PORT: 3306
      DB_DATABASE: pixelfed
      DB_USERNAME: pixelfed
      DB_PASSWORD: ${DB_PASS}
      REDIS_HOST: pixelfed-redis
      REDIS_PORT: 6379
      ACTIVITY_PUB: "true"
      AP_REMOTE_FOLLOW: "true"
      OPEN_REGISTRATION: "true"
    volumes:
      - ./storage:/var/www/storage
    depends_on:
      - pixelfed-mysql
      - pixelfed-redis

  pixelfed-mysql:
    image: mysql:8.0
    container_name: pixelfed-mysql
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_PASS}
      MYSQL_DATABASE: pixelfed
      MYSQL_USER: pixelfed
      MYSQL_PASSWORD: ${DB_PASS}
    volumes:
      - ./mysql:/var/lib/mysql

  pixelfed-redis:
    image: redis:7-alpine
    container_name: pixelfed-redis
    restart: unless-stopped
EOF
info "docker-compose.yml created."

section "Step 8: Starting Pixelfed"
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start."
else
    docker-compose up -d || error "Failed to start."
fi

section "Step 9: Health Check (~2 min)"
info "Waiting for Pixelfed to be ready..."
for i in $(seq 1 24); do
    if curl -sf --max-time 5 http://127.0.0.1:8085 &>/dev/null; then
        info "Pixelfed is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/24 — waiting 10s..."
    sleep 10
    echo " retrying"
done

section "Step 10: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 8085/tcp
    info "UFW: port 8085 opened."
else
    warn "UFW not found — skipping."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  📷  Pixelfed:                                     ║"
echo "  ║      👉  http://$APP_DOMAIN:8085"
echo "  ║                                                      ║"
echo "  ║  📝  Register at the URL above to get started.      ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  For federation: point DNS A record to this IP  ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║                                                      ║"
echo "  ║  ☕  Support This Script                             ║"
echo "  ║                                                      ║"
echo "  ║  If this script saved you time, consider sending a  ║"
echo "  ║  small tip in USDT. It keeps the content free and   ║"
echo "  ║  helps publish more guides.                         ║"
echo "  ║                                                      ║"
echo "  ║  USDT · TRC-20:                                     ║"
echo "  ║  TCSZTkXvhibdrFre5sdTsFLRQ6d6yQkd2i               ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  TRC-20 network only. Do not send on ERC-20.   ║"
echo "  ║      Funds sent on other networks cannot be         ║"
echo "  ║      recovered.                                     ║"
echo "  ║                                                      ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
