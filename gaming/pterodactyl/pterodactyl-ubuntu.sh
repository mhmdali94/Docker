#!/bin/bash
# ============================================================
#   Pterodactyl Panel Auto-Installer
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
echo "  ║     Pterodactyl Panel Auto-Installer            ║"
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
APP_KEY="base64:$(openssl rand -base64 32)"
HASH_KEY=$(openssl rand -hex 16)
SERVER_IP_DEFAULT=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
read -rp "  Enter your server IP or domain [$SERVER_IP_DEFAULT]: " SERVER_ADDR
SERVER_ADDR="${SERVER_ADDR:-$SERVER_IP_DEFAULT}"
read -rp "  Admin email [admin@pterodactyl.local]: " ADMIN_EMAIL
ADMIN_EMAIL="${ADMIN_EMAIL:-admin@pterodactyl.local}"
info "Server: $SERVER_ADDR"

section "Step 5: Cleaning Up Existing Containers"
for cname in pterodactyl-panel pterodactyl-mysql pterodactyl-redis pterodactyl-cache; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    [ -n "$EXISTING" ] && warn "Removing $cname..." && docker rm -f "$cname" 2>/dev/null || true
done

section "Step 6: Preparing Directory"
APP_DIR="/root/docker/pterodactyl"
mkdir -p "$APP_DIR/var" "$APP_DIR/nginx" "$APP_DIR/certs" "$APP_DIR/logs"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 7: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  pterodactyl-panel:
    image: ghcr.io/pterodactyl/panel:latest
    container_name: pterodactyl-panel
    restart: unless-stopped
    ports:
      - "8080:80"
      - "8443:443"
    environment:
      APP_URL: http://${SERVER_ADDR}:8080
      APP_KEY: ${APP_KEY}
      APP_ENV: production
      APP_DEBUG: "false"
      APP_TIMEZONE: UTC
      DB_CONNECTION: mysql
      DB_HOST: pterodactyl-mysql
      DB_PORT: 3306
      DB_DATABASE: pterodactyl
      DB_USERNAME: pterodactyl
      DB_PASSWORD: ${DB_PASS}
      CACHE_DRIVER: redis
      SESSION_DRIVER: redis
      QUEUE_DRIVER: redis
      REDIS_HOST: pterodactyl-redis
      HASHIDS_SALT: ${HASH_KEY}
      HASHIDS_LENGTH: 8
      MAIL_DRIVER: log
    volumes:
      - ./var:/app/var
      - ./nginx:/etc/nginx/http.d
      - ./certs:/etc/letsencrypt
      - ./logs:/app/storage/logs
    depends_on:
      - pterodactyl-mysql
      - pterodactyl-redis

  pterodactyl-mysql:
    image: mysql:8.0
    container_name: pterodactyl-mysql
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_PASS}
      MYSQL_DATABASE: pterodactyl
      MYSQL_USER: pterodactyl
      MYSQL_PASSWORD: ${DB_PASS}
    volumes:
      - ./mysql:/var/lib/mysql
    command: --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci

  pterodactyl-redis:
    image: redis:7-alpine
    container_name: pterodactyl-redis
    restart: unless-stopped
    volumes:
      - ./redis:/data
EOF
info "docker-compose.yml created."

section "Step 8: Starting Pterodactyl Panel"
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start."
else
    docker-compose up -d || error "Failed to start."
fi

section "Step 9: Health Check (~60s)"
info "Waiting for Pterodactyl Panel to be ready..."
for i in $(seq 1 18); do
    if curl -s --max-time 5 http://127.0.0.1:8080 &>/dev/null; then
        info "Pterodactyl Panel is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/18 — waiting 10s..."
    sleep 10
    echo " retrying"
done

section "Step 10: Creating Admin User"
info "Creating admin user..."
sleep 5
docker exec pterodactyl-panel php artisan p:user:make \
    --email="$ADMIN_EMAIL" \
    --username=admin \
    --name-first=Admin \
    --name-last=User \
    --password="$(openssl rand -base64 12 | tr -d '=+/')" \
    --admin=1 2>/dev/null || warn "Admin creation failed — run manually after setup."

section "Step 11: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 8080/tcp
    ufw allow 8443/tcp
    info "UFW: ports 8080 and 8443 opened."
else
    warn "UFW not found — skipping."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🦅  Pterodactyl Panel:                            ║"
echo "  ║      👉  http://$SERVER_ADDR:8080"
echo "  ║                                                      ║"
echo "  ║  📧  Admin email: $ADMIN_EMAIL"
echo "  ║      Reset password via:                            ║"
echo "  ║      docker exec pterodactyl-panel php artisan      ║"
echo "  ║        p:user:make                                  ║"
echo "  ║                                                      ║"
echo "  ║  🖥️  Next step: Install Wings (game node daemon)   ║"
echo "  ║      See README for Wings installation steps.       ║"
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
