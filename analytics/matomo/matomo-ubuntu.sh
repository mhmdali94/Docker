#!/bin/bash
# ============================================================
#   Matomo Auto-Installer
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
echo "  ║     Matomo Auto-Installer                       ║"
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
if ! command -v docker &>/dev/null; then
    warn "Docker not found. Installing..."
    apt update -y && apt install -y docker.io
    systemctl enable --now docker
    info "Docker installed."
else
    info "Docker: $(docker --version)"
fi

section "Step 3: Checking Docker Compose V2"
if ! docker compose version &>/dev/null; then
    warn "Docker Compose V2 not found. Installing..."
    apt update -y && apt install -y docker-compose-v2 || apt install -y docker-compose
    info "Docker Compose installed."
else
    info "Docker Compose: $(docker compose version)"
fi

section "Step 4: Cleaning Up Existing Containers"
for cname in matomo matomo-db; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    [ -n "$EXISTING" ] && warn "Removing $cname..." && docker rm -f "$cname" 2>/dev/null || true
done
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
APP_DIR="/root/docker/matomo"
mkdir -p "$APP_DIR"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 6: Generating Credentials & docker-compose.yml"
DB_PASS=$(openssl rand -hex 16)
info "Credentials generated."

cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  matomo-db:
    image: mariadb:10.11
    container_name: matomo-db
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_PASS}root
      MYSQL_DATABASE: matomo
      MYSQL_USER: matomo
      MYSQL_PASSWORD: ${DB_PASS}
    volumes:
      - ./mariadb:/var/lib/mysql

  matomo:
    image: matomo:latest
    container_name: matomo
    restart: unless-stopped
    ports:
      - "8085:80"
    environment:
      MATOMO_DATABASE_HOST: matomo-db
      MATOMO_DATABASE_DBNAME: matomo
      MATOMO_DATABASE_USERNAME: matomo
      MATOMO_DATABASE_PASSWORD: ${DB_PASS}
    volumes:
      - ./data:/var/www/html
    depends_on:
      - matomo-db
EOF
info "docker-compose.yml created."

section "Step 7: Starting Matomo"
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    if docker compose version &>/dev/null; then
        docker compose up -d && break
    else
        docker-compose up -d && break
    fi
    warn "Attempt $attempt/$MAX_RETRIES failed."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed after $MAX_RETRIES attempts. Run: cd $APP_DIR && docker compose up -d"
done

section "Step 8: Verifying Container"
sleep 8
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^matomo$' || true)
[ -z "$RUNNING" ] && warn "Container may not have started. Check: docker logs matomo" || info "Container running: $RUNNING"

section "Step 9: Health Check"
info "Waiting for Matomo on port 8085..."
HEALTH_OK=0
for i in $(seq 1 12); do
    if curl -s --max-time 3 http://127.0.0.1:8085 &>/dev/null; then
        info "Port 8085 is responding. ✅"; HEALTH_OK=1; break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."; sleep 5; echo " retrying"
done
[ "$HEALTH_OK" -eq 0 ] && warn "Not responding. Check: docker logs matomo"

section "Step 10: Opening Firewall"
if command -v ufw &>/dev/null; then
    ufw allow 8085/tcp; info "UFW: port 8085 opened."
else
    warn "UFW not found — skipping."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  📊  Matomo (Analytics):                           ║"
echo "  ║      👉  http://$SERVER_IP:8085"
echo "  ║                                                      ║"
echo "  ║  🔑  Complete setup wizard on first visit.         ║"
echo "  ║      DB Host : matomo-db                           ║"
echo "  ║      DB Name : matomo                              ║"
echo "  ║      DB User : matomo                              ║"
echo "  ║      DB Pass : $DB_PASS"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║  🚀  Need production setup?                         ║"
echo "  ║      👨‍💻  Mohammed Ali Elshikh                      ║"
echo "  ║      🌐  prismatechwork.com                         ║"
echo "  ║  ☕  USDT (TRC-20): TCSZTkXvhibdrFre5sdTsFLRQ6d6yQkd2i ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
