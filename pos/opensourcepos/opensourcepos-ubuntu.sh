#!/bin/bash
# ============================================================
#   Open Source POS Auto-Installer
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
echo "  ║     Open Source POS Auto-Installer              ║"
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

section "Step 4: Cleaning Up Existing Containers"
for cname in opensourcepos opensourcepos-mysql; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    [ -n "$EXISTING" ] && warn "Removing $cname..." && docker rm -f "$cname" 2>/dev/null || true
done
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
APP_DIR="/root/docker/opensourcepos"
if [ -d "$APP_DIR" ]; then
    warn "Removing old directory $APP_DIR..."
    rm -rf "$APP_DIR"
fi
mkdir -p "$APP_DIR"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 6: Detecting Server IP"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
info "Server IP: $SERVER_IP"
info "Admin User     : admin"
info "Admin Password : pointofsale  (change after first login!)"

section "Step 7: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<'EOF'
volumes:
  uploads:
    driver: local
  logs:
    driver: local
  mysql:
    driver: local

networks:
  app_net:

services:
  mysql:
    image: mariadb:10.5
    container_name: opensourcepos-mysql
    restart: unless-stopped
    networks:
      - app_net
    volumes:
      - mysql:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: pointofsale
      MYSQL_DATABASE: ospos
      MYSQL_USER: admin
      MYSQL_PASSWORD: pointofsale

  opensourcepos:
    image: jekkos/opensourcepos:master
    container_name: opensourcepos
    restart: unless-stopped
    depends_on:
      - mysql
    ports:
      - "8888:80"
    networks:
      - app_net
    volumes:
      - uploads:/app/public/uploads
      - logs:/app/writable/log
    environment:
      CI_ENVIRONMENT: production
      MYSQL_HOST_NAME: mysql
      MYSQL_DB_NAME: ospos
      MYSQL_USERNAME: admin
      MYSQL_PASSWORD: pointofsale
EOF
info "docker-compose.yml created."

section "Step 8: Starting Open Source POS"
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    if docker compose version &> /dev/null; then
        docker compose up -d && break
    else
        docker-compose up -d && break
    fi
    warn "Docker pull failed on attempt $attempt/$MAX_RETRIES (registry may be temporarily unavailable)."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed to start after $MAX_RETRIES attempts. Run manually: cd $APP_DIR && docker compose up -d"
done

section "Step 9: Verifying Container"
sleep 15
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^opensourcepos$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs opensourcepos"
else
    info "Container running: $RUNNING"
fi

section "Step 10: Health Check (~3 min for first install)"
info "Waiting for Open Source POS to be ready on port 8888..."
HEALTH_OK=0
for i in $(seq 1 24); do
    if curl -s --max-time 5 http://127.0.0.1:8888 &>/dev/null; then
        info "Port 8888 is responding — Open Source POS is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/24 — waiting 10s..."
    sleep 10
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    warn "Open Source POS may still be starting. Check: docker logs opensourcepos"
fi

section "Step 11: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 8888/tcp
    info "UFW: port 8888/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🛒  Open Source POS URL:                          ║"
echo "  ║      👉  http://$SERVER_IP:8888"
echo "  ║                                                      ║"
echo "  ║  🔑  Default Login Credentials:                    ║"
echo "  ║      Username : admin                               ║"
echo "  ║      Password : pointofsale                         ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  Change the default password after first login! ║"
echo "  ║                                                      ║"
echo "  ║  📁  Data Location:                                ║"
echo "  ║      $APP_DIR"
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
