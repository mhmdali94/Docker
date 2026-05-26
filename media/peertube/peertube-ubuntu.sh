#!/bin/bash
# ============================================================
#   PeerTube Auto-Installer
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
echo "  ║     PeerTube Auto-Installer                     ║"
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
echo "  ⚠️  PeerTube requires a real domain name — video federation uses it."
echo ""
read -rp "  Enter your domain (e.g. video.example.com): " PEERTUBE_DOMAIN
[ -z "$PEERTUBE_DOMAIN" ] && error "Domain is required."
ADMIN_EMAIL="admin@${PEERTUBE_DOMAIN}"
DB_PASS=$(openssl rand -hex 16)
SECRET=$(openssl rand -hex 32)
info "Domain: $PEERTUBE_DOMAIN"

section "Step 5: Cleaning Up Existing Containers"
for cname in peertube peertube-postgres peertube-redis; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    [ -n "$EXISTING" ] && warn "Removing $cname..." && docker rm -f "$cname" 2>/dev/null || true
done

section "Step 6: Preparing Directory"
APP_DIR="/root/docker/peertube"
mkdir -p "$APP_DIR/data" "$APP_DIR/config"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 7: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  peertube:
    image: chocobozzz/peertube:production-bookworm
    container_name: peertube
    restart: unless-stopped
    ports:
      - "9300:9000"
    environment:
      PEERTUBE_DB_USERNAME: peertube
      PEERTUBE_DB_PASSWORD: ${DB_PASS}
      PEERTUBE_DB_HOSTNAME: peertube-postgres
      PEERTUBE_REDIS_HOSTNAME: peertube-redis
      PEERTUBE_WEBSERVER_HOSTNAME: ${PEERTUBE_DOMAIN}
      PEERTUBE_WEBSERVER_PORT: 9300
      PEERTUBE_WEBSERVER_HTTPS: "false"
      PEERTUBE_SMTP_HOSTNAME: ""
      PEERTUBE_ADMIN_EMAIL: ${ADMIN_EMAIL}
      PEERTUBE_SECRET: ${SECRET}
    volumes:
      - ./data:/data
      - ./config:/config
    depends_on:
      - peertube-postgres
      - peertube-redis

  peertube-postgres:
    image: postgres:15-alpine
    container_name: peertube-postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: peertube
      POSTGRES_USER: peertube
      POSTGRES_PASSWORD: ${DB_PASS}
    volumes:
      - ./postgres:/var/lib/postgresql/data

  peertube-redis:
    image: redis:7-alpine
    container_name: peertube-redis
    restart: unless-stopped
    volumes:
      - ./redis:/data
EOF
info "docker-compose.yml created."

section "Step 8: Starting PeerTube"
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start."
else
    docker-compose up -d || error "Failed to start."
fi

section "Step 9: Health Check (~90s for first start)"
info "Waiting for PeerTube to be ready..."
for i in $(seq 1 18); do
    if curl -sf --max-time 5 http://127.0.0.1:9300 &>/dev/null; then
        info "PeerTube is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/18 — waiting 10s..."
    sleep 10
    echo " retrying"
done

section "Step 10: Getting Admin Password"
info "Retrieving generated admin password..."
sleep 5
ADMIN_PASS=$(docker logs peertube 2>&1 | grep -i "root password" | tail -1 | awk '{print $NF}' || echo "Check: docker logs peertube")

section "Step 11: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 9300/tcp
    info "UFW: port 9300 opened."
else
    warn "UFW not found — skipping."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  📺  PeerTube:                                     ║"
echo "  ║      👉  http://$PEERTUBE_DOMAIN:9300"
echo "  ║                                                      ║"
echo "  ║  🔑  Admin credentials:                            ║"
echo "  ║      Email: $ADMIN_EMAIL"
echo "  ║      Password: check with:"
echo "  ║      docker logs peertube 2>&1 | grep -i password   ║"
echo "  ║                                                      ║"
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
