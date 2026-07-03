#!/bin/bash
# ============================================================
#   Shlink Auto-Installer
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
echo "  ║     Shlink Auto-Installer                       ║"
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
SERVER_IP_DEFAULT=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  Shlink requires a domain or IP to generate short URLs."
echo ""
read -rp "  Enter your domain or IP [$SERVER_IP_DEFAULT]: " SERVER_ADDR
SERVER_ADDR="${SERVER_ADDR:-$SERVER_IP_DEFAULT}"
DB_PASS=$(openssl rand -hex 16)
API_KEY=$(openssl rand -hex 20)
info "Short URL base: http://$SERVER_ADDR:8585"

section "Step 5: Cleaning Up Existing Containers"
for cname in shlink shlink-db shlink-web; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    [ -n "$EXISTING" ] && warn "Removing $cname..." && docker rm -f "$cname" 2>/dev/null || true
done

section "Step 6: Preparing Directory"
APP_DIR="/root/docker/shlink"
mkdir -p "$APP_DIR"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 7: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  shlink:
    image: shlinkio/shlink:stable
    container_name: shlink
    restart: unless-stopped
    ports:
      - "8585:8080"
    environment:
      DEFAULT_DOMAIN: ${SERVER_ADDR}:8585
      IS_HTTPS_ENABLED: "false"
      DB_DRIVER: postgres
      DB_HOST: shlink-db
      DB_NAME: shlink
      DB_USER: shlink
      DB_PASSWORD: ${DB_PASS}
      INITIAL_API_KEY: ${API_KEY}
    depends_on:
      - shlink-db

  shlink-db:
    image: postgres:15-alpine
    container_name: shlink-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: shlink
      POSTGRES_USER: shlink
      POSTGRES_PASSWORD: ${DB_PASS}
    volumes:
      - ./postgres:/var/lib/postgresql/data

  shlink-web:
    image: shlinkio/shlink-web-client:stable
    container_name: shlink-web
    restart: unless-stopped
    ports:
      - "8586:8080"
EOF
info "docker-compose.yml created."

section "Step 8: Starting Shlink"
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start."
else
    docker-compose up -d || error "Failed to start."
fi

section "Step 9: Health Check"
info "Waiting for Shlink to be ready..."
for i in $(seq 1 12); do
    if curl -s --max-time 3 http://127.0.0.1:8585/rest/v3/health &>/dev/null; then
        info "Shlink is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done

section "Step 10: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 8585/tcp
    ufw allow 8586/tcp
    info "UFW: ports 8585 and 8586 opened."
else
    warn "UFW not found — skipping."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🔗  Shlink API:                                   ║"
echo "  ║      👉  http://$SERVER_ADDR:8585"
echo "  ║                                                      ║"
echo "  ║  🖥️   Shlink Dashboard:                            ║"
echo "  ║      👉  http://$SERVER_ADDR:8586"
echo "  ║                                                      ║"
echo "  ║  🔑  API Key:                                      ║"
printf  "  ║      %-50s║\n" "$API_KEY"
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
