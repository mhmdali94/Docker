#!/bin/bash
#
# ============================================================
#   Dify Auto-Installer
#   Made by: Mohammed Ali Elshikh | prismatechwork.com
#
#   ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️
#   This script is NOT intended for production use.
# ============================================================

set -e

info()    { echo -e "\e[32m[INFO]\e[0m $*"; }
warn()    { echo -e "\e[33m[WARN]\e[0m $*"; }
error()   { echo -e "\e[31m[ERROR]\e[0m $*"; exit 1; }
section() { echo -e "\n\e[36m========== $* ==========\e[0m"; }

clear
echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║         Dify Auto-Installer                      ║"
echo "  ║         Made by: Mohammed Ali Elshikh           ║"
echo "  ║         prismatechwork.com                      ║"
echo "  ║                                                  ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️         ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║                                                      ║"
echo "  ║  ⚠️   DEMO / TESTING USE ONLY                        ║"
echo "  ║                                                      ║"
echo "  ║  This installer is intended for demo and testing.   ║"
echo "  ║  For a production-ready, hardened setup contact:    ║"
echo "  ║                                                      ║"
echo "  ║  👨‍💻  Mohammed Ali Elshikh                            ║"
echo "  ║  🌐  prismatechwork.com                              ║"
echo "  ║                                                      ║"
echo "  ║  Press ENTER to continue with demo install...       ║"
echo "  ║  Press Ctrl+C to cancel.                            ║"
echo "  ║                                                      ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
read -rp "" _DEMO_CONFIRM

section "Step 0: Checking Privileges"
if [ "$EUID" -ne 0 ]; then error "Please run as root: sudo bash $0"; fi
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
for cname in dify-nginx dify-web dify-api dify-worker dify-sandbox dify-db dify-redis; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    if [ -n "$EXISTING" ]; then
        warn "Removing existing container: $cname"
        docker rm -f "$cname" 2>/dev/null || true
    fi
done
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
DIFY_DIR="/root/docker/dify"
if [ -d "$DIFY_DIR" ]; then
    warn "Removing old directory $DIFY_DIR..."
    rm -rf "$DIFY_DIR"
fi
mkdir -p "$DIFY_DIR/storage"
cd "$DIFY_DIR" || error "Cannot navigate to $DIFY_DIR"
info "Directory ready: $DIFY_DIR"

section "Step 6: Generating Credentials & Writing Config"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
SECRET=$(tr -dc 'a-f0-9' < /dev/urandom | head -c 64)
SANDBOX_KEY=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)
info "Setup wizard at http://$SERVER_IP:3050 after start."

cat > "$DIFY_DIR/nginx.conf" <<'NGINXEOF'
upstream dify-api {
    server dify-api:5001;
}
upstream dify-web {
    server dify-web:3000;
}
server {
    listen 80;
    server_name _;
    client_max_body_size 15M;
    location /console/api { proxy_pass http://dify-api; proxy_set_header Host $http_host; proxy_set_header X-Real-IP $remote_addr; }
    location /api { proxy_pass http://dify-api; proxy_set_header Host $http_host; proxy_set_header X-Real-IP $remote_addr; }
    location /v1 { proxy_pass http://dify-api; proxy_set_header Host $http_host; proxy_set_header X-Real-IP $remote_addr; }
    location /files { proxy_pass http://dify-api; proxy_set_header Host $http_host; proxy_set_header X-Real-IP $remote_addr; }
    location / { proxy_pass http://dify-web; proxy_set_header Host $http_host; proxy_set_header X-Real-IP $remote_addr; }
}
NGINXEOF

cat > "$DIFY_DIR/docker-compose.yml" <<EOF
services:
  dify-db:
    image: postgres:15
    container_name: dify-db
    restart: unless-stopped
    environment:
      POSTGRES_USER: dify
      POSTGRES_PASSWORD: $DB_PASS
      POSTGRES_DB: dify
    volumes:
      - ./postgres:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U dify"]
      interval: 5s
      timeout: 5s
      retries: 10

  dify-redis:
    image: redis:6
    container_name: dify-redis
    restart: unless-stopped
    command: redis-server --save 20 1 --loglevel warning
    volumes:
      - ./redis:/data

  dify-sandbox:
    image: langgenius/dify-sandbox:0.2.10
    container_name: dify-sandbox
    restart: unless-stopped
    environment:
      API_KEY: $SANDBOX_KEY
      GIN_MODE: release
      WORKER_TIMEOUT: 15

  dify-api:
    image: langgenius/dify-api:0.9.1
    container_name: dify-api
    restart: unless-stopped
    environment:
      MODE: api
      LOG_LEVEL: INFO
      SECRET_KEY: $SECRET
      DB_USERNAME: dify
      DB_PASSWORD: $DB_PASS
      DB_HOST: dify-db
      DB_PORT: 5432
      DB_DATABASE: dify
      REDIS_HOST: dify-redis
      REDIS_PORT: 6379
      CELERY_BROKER_URL: redis://dify-redis:6379/1
      STORAGE_TYPE: local
      STORAGE_LOCAL_PATH: /app/api/storage
      SANDBOX_HOST: dify-sandbox
      SANDBOX_PORT: 8194
      CODE_EXECUTION_API_KEY: $SANDBOX_KEY
      CONSOLE_WEB_URL: http://$SERVER_IP:3050
      SERVICE_API_URL: http://$SERVER_IP:3050
    volumes:
      - ./storage:/app/api/storage
    depends_on:
      dify-db:
        condition: service_healthy
      dify-redis:
        condition: service_started
      dify-sandbox:
        condition: service_started

  dify-worker:
    image: langgenius/dify-api:0.9.1
    container_name: dify-worker
    restart: unless-stopped
    environment:
      MODE: worker
      LOG_LEVEL: INFO
      SECRET_KEY: $SECRET
      DB_USERNAME: dify
      DB_PASSWORD: $DB_PASS
      DB_HOST: dify-db
      DB_PORT: 5432
      DB_DATABASE: dify
      REDIS_HOST: dify-redis
      REDIS_PORT: 6379
      CELERY_BROKER_URL: redis://dify-redis:6379/1
      STORAGE_TYPE: local
      STORAGE_LOCAL_PATH: /app/api/storage
      SANDBOX_HOST: dify-sandbox
      SANDBOX_PORT: 8194
      CODE_EXECUTION_API_KEY: $SANDBOX_KEY
    volumes:
      - ./storage:/app/api/storage
    depends_on:
      dify-db:
        condition: service_healthy
      dify-redis:
        condition: service_started
      dify-sandbox:
        condition: service_started

  dify-web:
    image: langgenius/dify-web:0.9.1
    container_name: dify-web
    restart: unless-stopped
    environment:
      CONSOLE_API_URL: http://$SERVER_IP:3050
      APP_API_URL: http://$SERVER_IP:3050

  dify-nginx:
    image: nginx:1.25-alpine
    container_name: dify-nginx
    restart: unless-stopped
    ports:
      - "3050:80"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      - dify-api
      - dify-web
EOF
info "docker-compose.yml created."

section "Step 7: Starting Dify"
MAX_RETRIES=3
info "Starting database and dependencies first..."
for attempt in $(seq 1 $MAX_RETRIES); do
    if docker compose version &> /dev/null; then
        docker compose up -d dify-db dify-redis dify-sandbox && break
    else
        docker-compose up -d dify-db dify-redis dify-sandbox && break
    fi
    warn "Docker pull failed on attempt $attempt/$MAX_RETRIES."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed to start after $MAX_RETRIES attempts."
done

info "Waiting for database to be ready..."
for i in $(seq 1 40); do
    if docker exec dify-db pg_isready -U dify -d dify &>/dev/null; then
        info "Database is ready."
        break
    fi
    sleep 3
done
sleep 5

info "Starting full stack..."
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

info "Waiting for API container to be running..."
for i in $(seq 1 30); do
    if docker ps --format '{{.Names}}' | grep -q '^dify-api$'; then
        break
    fi
    sleep 3
done
sleep 5

info "Running database migrations..."
docker exec dify-api flask db upgrade
info "Restarting API and worker..."
docker restart dify-api dify-worker &>/dev/null
info "Dify started successfully."

section "Step 8: Verifying Container"
sleep 15
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^dify-nginx$' || true)
if [ -z "$RUNNING" ]; then
    warn "Dify nginx may not have started. Check: docker logs dify-nginx"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for Dify to be ready on port 3050 (may take ~3 minutes)..."
HEALTH_OK=0
for i in $(seq 1 24); do
    if curl -s --max-time 5 http://127.0.0.1:3050 &>/dev/null; then
        info "Port 3050 is responding — Dify is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/24 — waiting 10s..."
    sleep 10
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    warn "Dify may still be initializing. Check: docker logs dify-api"
fi

section "Step 10: Opening Firewall Port 3050"
if command -v ufw &> /dev/null; then
    ufw allow 3050/tcp
    info "UFW: port 3050/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Dify in your browser:                  ║"
echo "  ║      👉  http://$SERVER_IP:3050"
echo "  ║                                                      ║"
echo "  ║  🔑  Complete the setup wizard on first visit.     ║"
echo "  ║      Then add LLM providers under Settings.        ║"
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
