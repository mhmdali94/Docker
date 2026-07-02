#!/bin/bash
# ============================================================
#   Medusa Auto-Installer
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
echo "  ║     Medusa Auto-Installer                       ║"
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
JWT_SECRET=$(openssl rand -hex 32)
COOKIE_SECRET=$(openssl rand -hex 32)
ADMIN_PASS=$(openssl rand -base64 12 | tr -d '=+/')
info "Secrets generated."

section "Step 5: Cleaning Up Existing Containers"
for cname in medusa medusa-postgres medusa-redis; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    [ -n "$EXISTING" ] && warn "Removing $cname..." && docker rm -f "$cname" 2>/dev/null || true
done
if docker image inspect medusa-local &>/dev/null; then
    warn "Removing existing medusa-local image..."
    docker rmi -f medusa-local 2>/dev/null || true
fi

section "Step 6: Preparing Directory"
APP_DIR="/root/docker/medusa"
mkdir -p "$APP_DIR"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 7: Writing Dockerfile & docker-compose.yml"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)

cat > "$APP_DIR/Dockerfile" <<'DOCKERFILE'
FROM node:20-alpine
RUN apk add --no-cache git python3 make g++
RUN git clone --depth 1 https://github.com/medusajs/medusa-starter-default /app
WORKDIR /app
RUN yarn install || npm install --legacy-peer-deps
EXPOSE 9000
CMD ["sh", "-c", "npx medusa db:migrate && (npx medusa user -e admin@medusa.local -p \"$ADMIN_PASS\" || true) && npx medusa develop -H 0.0.0.0"]
DOCKERFILE

cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  medusa:
    image: medusa-local
    container_name: medusa
    restart: unless-stopped
    ports:
      - "9000:9000"
    environment:
      DATABASE_URL: postgres://medusa:${DB_PASS}@medusa-postgres:5432/medusa
      REDIS_URL: redis://medusa-redis:6379
      JWT_SECRET: ${JWT_SECRET}
      COOKIE_SECRET: ${COOKIE_SECRET}
      ADMIN_PASS: ${ADMIN_PASS}
      STORE_CORS: http://${SERVER_IP}:9000
      ADMIN_CORS: http://${SERVER_IP}:9000
      AUTH_CORS: http://${SERVER_IP}:9000
    depends_on:
      - medusa-postgres
      - medusa-redis

  medusa-postgres:
    image: postgres:15-alpine
    container_name: medusa-postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: medusa
      POSTGRES_USER: medusa
      POSTGRES_PASSWORD: ${DB_PASS}
    volumes:
      - ./postgres:/var/lib/postgresql/data

  medusa-redis:
    image: redis:7-alpine
    container_name: medusa-redis
    restart: unless-stopped
    volumes:
      - ./redis:/data
EOF
info "Dockerfile and docker-compose.yml created."

section "Step 8: Building & Starting Medusa"
info "Building Medusa from the official starter (source build — takes several minutes)..."
docker build --no-cache -t medusa-local "$APP_DIR" || error "Docker build failed."
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start. Run: cd $APP_DIR && docker compose up -d"
else
    docker-compose up -d || error "Failed to start. Run: cd $APP_DIR && docker-compose up -d"
fi

section "Step 9: Health Check (~90s for first start)"
info "Waiting for Medusa to be ready (migrations run on first start)..."
for i in $(seq 1 18); do
    if curl -s --max-time 5 http://127.0.0.1:9000/health &>/dev/null; then
        info "Medusa is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/18 — waiting 10s..."
    sleep 10
    echo " retrying"
done

section "Step 10: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 9000/tcp
    info "UFW: port 9000 opened."
else
    warn "UFW not found — skipping."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🛒  Medusa Backend API:                           ║"
echo "  ║      👉  http://$SERVER_IP:9000"
echo "  ║                                                      ║"
echo "  ║  ⚙️   Admin Dashboard:                             ║"
echo "  ║      👉  http://$SERVER_IP:9000/app"
echo "  ║      Login: admin@medusa.local / $ADMIN_PASS"
echo "  ║                                                      ║"
echo "  ║  🛍️   Store API: http://$SERVER_IP:9000/store"
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
