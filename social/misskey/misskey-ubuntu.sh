#!/bin/bash
# ============================================================
#   Misskey Auto-Installer
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
echo "  ║     Misskey Auto-Installer                      ║"
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
for cname in misskey misskey-db misskey-redis; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    [ -n "$EXISTING" ] && warn "Removing $cname..." && docker rm -f "$cname" 2>/dev/null || true
done
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
APP_DIR="/root/docker/misskey"
mkdir -p "$APP_DIR"/{config,files}
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 6: Generating Credentials & Configuration"
DB_PASS=$(openssl rand -hex 16)
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)

cat > "$APP_DIR/config/default.yml" <<EOF
url: http://${SERVER_IP}:3001

db:
  host: misskey-db
  port: 5432
  db: misskey
  user: misskey
  pass: ${DB_PASS}

redis:
  host: misskey-redis
  port: 6379

port: 3000
id: aidx
EOF

cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  misskey-db:
    image: postgres:15-alpine
    container_name: misskey-db
    restart: unless-stopped
    environment:
      POSTGRES_USER: misskey
      POSTGRES_PASSWORD: ${DB_PASS}
      POSTGRES_DB: misskey
    volumes:
      - ./postgres:/var/lib/postgresql/data

  misskey-redis:
    image: redis:7-alpine
    container_name: misskey-redis
    restart: unless-stopped
    volumes:
      - ./redis:/data

  misskey:
    image: misskey/misskey:latest
    container_name: misskey
    restart: unless-stopped
    ports:
      - "3001:3000"
    volumes:
      - ./config:/misskey/.config
      - ./files:/misskey/files
    depends_on:
      - misskey-db
      - misskey-redis
EOF
info "docker-compose.yml and config created."

section "Step 7: Starting Misskey"
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    if docker compose version &>/dev/null; then
        docker compose up -d && break
    else
        docker-compose up -d && break
    fi
    warn "Attempt $attempt/$MAX_RETRIES failed."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed after $MAX_RETRIES attempts."
done

section "Step 8: Health Check"
info "Waiting for Misskey on port 3001 (first start takes a few minutes)..."
HEALTH_OK=0
for i in $(seq 1 18); do
    if curl -s --max-time 5 http://127.0.0.1:3001 &>/dev/null; then
        info "Port 3001 is responding. ✅"; HEALTH_OK=1; break
    fi
    echo -n "  Attempt $i/18 — waiting 10s..."; sleep 10; echo " retrying"
done
[ "$HEALTH_OK" -eq 0 ] && warn "Not responding. Check: docker logs misskey"

section "Step 9: Opening Firewall"
if command -v ufw &>/dev/null; then
    ufw allow 3001/tcp; info "UFW: port 3001 opened."
else
    warn "UFW not found — skipping."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🌐  Misskey (Fediverse Platform):                 ║"
echo "  ║      👉  http://$SERVER_IP:3001"
echo "  ║                                                      ║"
echo "  ║  🔑  Complete setup wizard on first visit.         ║"
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
