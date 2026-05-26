#!/bin/bash
# ============================================================
#   Zammad Auto-Installer
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
echo "  ║     Zammad Auto-Installer                       ║"
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
for cname in zammad-railsserver zammad-websocket zammad-scheduler zammad-worker zammad-nginx zammad-postgresql zammad-redis zammad-elasticsearch zammad-init zammad-memcached; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    [ -n "$EXISTING" ] && warn "Removing $cname..." && docker rm -f "$cname" 2>/dev/null || true
done

section "Step 5: Preparing Directory"
APP_DIR="/root/docker/zammad"
mkdir -p "$APP_DIR"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 6: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<'EOF'
services:
  zammad-elasticsearch:
    image: bitnami/elasticsearch:8
    container_name: zammad-elasticsearch
    restart: unless-stopped
    volumes:
      - ./elasticsearch:/bitnami/elasticsearch/data
    environment:
      ELASTICSEARCH_ENABLE_SECURITY: "false"
      ELASTICSEARCH_SKIP_TRANSPORT_TLS: "true"

  zammad-postgresql:
    image: postgres:15-alpine
    container_name: zammad-postgresql
    restart: unless-stopped
    environment:
      POSTGRES_DB: zammad
      POSTGRES_USER: zammad
      POSTGRES_PASSWORD: zammad_password
    volumes:
      - ./postgres:/var/lib/postgresql/data

  zammad-redis:
    image: redis:7-alpine
    container_name: zammad-redis
    restart: unless-stopped

  zammad-memcached:
    image: memcached:1.6-alpine
    container_name: zammad-memcached
    restart: unless-stopped
    command: memcached -m 256

  zammad-init:
    image: ghcr.io/zammad/zammad:latest
    container_name: zammad-init
    restart: on-failure
    environment:
      POSTGRESQL_HOST: zammad-postgresql
      POSTGRESQL_DB: zammad
      POSTGRESQL_USER: zammad
      POSTGRESQL_PASS: zammad_password
      REDIS_URL: redis://zammad-redis:6379
      ELASTICSEARCH_HOST: zammad-elasticsearch
      MEMCACHE_SERVERS: zammad-memcached:11211
    depends_on:
      - zammad-postgresql
      - zammad-elasticsearch
      - zammad-redis
    command: ["zammad", "init"]
    volumes:
      - ./storage:/opt/zammad/storage

  zammad-railsserver:
    image: ghcr.io/zammad/zammad:latest
    container_name: zammad-railsserver
    restart: unless-stopped
    environment:
      POSTGRESQL_HOST: zammad-postgresql
      POSTGRESQL_DB: zammad
      POSTGRESQL_USER: zammad
      POSTGRESQL_PASS: zammad_password
      REDIS_URL: redis://zammad-redis:6379
      ELASTICSEARCH_HOST: zammad-elasticsearch
      MEMCACHE_SERVERS: zammad-memcached:11211
    depends_on:
      - zammad-init
      - zammad-postgresql
    command: ["zammad", "web"]
    volumes:
      - ./storage:/opt/zammad/storage

  zammad-websocket:
    image: ghcr.io/zammad/zammad:latest
    container_name: zammad-websocket
    restart: unless-stopped
    environment:
      POSTGRESQL_HOST: zammad-postgresql
      POSTGRESQL_DB: zammad
      POSTGRESQL_USER: zammad
      POSTGRESQL_PASS: zammad_password
      REDIS_URL: redis://zammad-redis:6379
    depends_on:
      - zammad-railsserver
    command: ["zammad", "websocket"]
    volumes:
      - ./storage:/opt/zammad/storage

  zammad-scheduler:
    image: ghcr.io/zammad/zammad:latest
    container_name: zammad-scheduler
    restart: unless-stopped
    environment:
      POSTGRESQL_HOST: zammad-postgresql
      POSTGRESQL_DB: zammad
      POSTGRESQL_USER: zammad
      POSTGRESQL_PASS: zammad_password
      REDIS_URL: redis://zammad-redis:6379
      ELASTICSEARCH_HOST: zammad-elasticsearch
    depends_on:
      - zammad-railsserver
    command: ["zammad", "scheduler"]
    volumes:
      - ./storage:/opt/zammad/storage

  zammad-nginx:
    image: ghcr.io/zammad/zammad:latest
    container_name: zammad-nginx
    restart: unless-stopped
    ports:
      - "3036:8080"
    depends_on:
      - zammad-railsserver
      - zammad-websocket
    command: ["zammad", "nginx"]
    volumes:
      - ./storage:/opt/zammad/storage
EOF
info "docker-compose.yml created."

section "Step 7: Starting Zammad (~3 min for init)"
warn "Zammad has many components — first start takes 2-4 minutes."
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start."
else
    docker-compose up -d || error "Failed to start."
fi

section "Step 8: Health Check"
info "Waiting for Zammad to be ready..."
for i in $(seq 1 36); do
    if curl -sf --max-time 5 http://127.0.0.1:3036 &>/dev/null; then
        info "Zammad is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/36 — waiting 10s..."
    sleep 10
    echo " retrying"
done

section "Step 9: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 3036/tcp
    info "UFW: port 3036 opened."
else
    warn "UFW not found — skipping."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🎫  Zammad Helpdesk:                              ║"
echo "  ║      👉  http://$SERVER_IP:3036"
echo "  ║                                                      ║"
echo "  ║  📝  First visit: run the setup wizard              ║"
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
