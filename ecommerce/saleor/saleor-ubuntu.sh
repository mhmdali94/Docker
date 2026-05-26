#!/bin/bash
# ============================================================
#   Saleor Auto-Installer
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
echo "  ║     Saleor Auto-Installer                       ║"
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
read -rp "  Enter your server IP or domain [$SERVER_IP_DEFAULT]: " SERVER_ADDR
SERVER_ADDR="${SERVER_ADDR:-$SERVER_IP_DEFAULT}"
DB_PASS=$(openssl rand -hex 16)
SECRET_KEY=$(openssl rand -hex 32)
info "Using server: $SERVER_ADDR"

section "Step 5: Cleaning Up Existing Containers"
for cname in saleor saleor-api saleor-dashboard saleor-postgres saleor-redis; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    [ -n "$EXISTING" ] && warn "Removing $cname..." && docker rm -f "$cname" 2>/dev/null || true
done

section "Step 6: Preparing Directory"
APP_DIR="/root/docker/saleor"
mkdir -p "$APP_DIR/media"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 7: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  saleor-api:
    image: ghcr.io/saleor/saleor:latest
    container_name: saleor-api
    restart: unless-stopped
    ports:
      - "8010:8000"
    environment:
      DATABASE_URL: postgres://saleor:${DB_PASS}@saleor-postgres:5432/saleor
      CELERY_BROKER_URL: redis://saleor-redis:6379/1
      REDIS_URL: redis://saleor-redis:6379/0
      SECRET_KEY: ${SECRET_KEY}
      ALLOWED_HOSTS: ${SERVER_ADDR},localhost,127.0.0.1
      ALLOWED_CLIENT_HOSTS: ${SERVER_ADDR},localhost
      DEFAULT_FROM_EMAIL: noreply@${SERVER_ADDR}
    volumes:
      - ./media:/app/media
    depends_on:
      - saleor-postgres
      - saleor-redis
    command: >
      sh -c "python manage.py migrate &&
             python manage.py collectstatic --noinput &&
             gunicorn saleor.asgi:application --bind 0.0.0.0:8000 -k uvicorn.workers.UvicornWorker"

  saleor-dashboard:
    image: ghcr.io/saleor/saleor-dashboard:latest
    container_name: saleor-dashboard
    restart: unless-stopped
    ports:
      - "9001:80"
    environment:
      API_URL: http://${SERVER_ADDR}:8010/graphql/

  saleor-postgres:
    image: postgres:15-alpine
    container_name: saleor-postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: saleor
      POSTGRES_USER: saleor
      POSTGRES_PASSWORD: ${DB_PASS}
    volumes:
      - ./postgres:/var/lib/postgresql/data

  saleor-redis:
    image: redis:7-alpine
    container_name: saleor-redis
    restart: unless-stopped
    volumes:
      - ./redis:/data
EOF
info "docker-compose.yml created."

section "Step 8: Starting Saleor"
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start. Run: cd $APP_DIR && docker compose up -d"
else
    docker-compose up -d || error "Failed to start. Run: cd $APP_DIR && docker-compose up -d"
fi

section "Step 9: Health Check (~2 min for migrations)"
info "Waiting for Saleor API to be ready..."
for i in $(seq 1 24); do
    if curl -s --max-time 5 http://127.0.0.1:8010/health/ &>/dev/null; then
        info "Saleor API is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/24 — waiting 10s..."
    sleep 10
    echo " retrying"
done

section "Step 10: Creating Admin User"
info "Creating superuser..."
docker exec saleor-api python manage.py createsuperuser \
    --email admin@saleor.local \
    --first-name Admin \
    --last-name User \
    --no-input 2>/dev/null && info "Superuser created." || warn "Superuser creation skipped (may already exist)."

section "Step 11: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 8010/tcp
    ufw allow 9001/tcp
    info "UFW: ports 8010 and 9001 opened."
else
    warn "UFW not found — skipping."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🛒  Saleor GraphQL API:                           ║"
echo "  ║      👉  http://$SERVER_ADDR:8010/graphql/"
echo "  ║                                                      ║"
echo "  ║  ⚙️   Saleor Dashboard:                            ║"
echo "  ║      👉  http://$SERVER_ADDR:9001"
echo "  ║                                                      ║"
echo "  ║  🔑  Admin: admin@saleor.local                     ║"
echo "  ║      Set password via dashboard or CLI             ║"
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
