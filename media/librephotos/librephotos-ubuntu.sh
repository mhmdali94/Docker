#!/bin/bash
# ============================================================
#   LibrePhotos Auto-Installer
#   Made by: Mohammed Ali Elshikh | prismatechwork.com
#   ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️
# ============================================================
set -e

info()    { echo -e "\e[32m[INFO]\e[0m $*"; }
warn()    { echo -e "\e[33m[WARN]\e[0m $*"; }
error()   { echo -e "\e[31m[ERROR]\e[0m $*"; exit 1; }
section() { echo -e "\n\e[36m========== $* ==========\e[0m"; }

clear
echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║   LibrePhotos Auto-Installer"
echo "  ║   Made by: Mohammed Ali Elshikh"
echo "  ║   prismatechwork.com"
echo "  ║"
echo "  ║   ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║  ⚠️   DEMO / TESTING USE ONLY                        ║"
echo "  ║  Press ENTER to continue... Ctrl+C to cancel.       ║"
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

section "Step 4: Cleaning Up Existing Containers & Data"
SERVICE_DIR="/root/docker/librephotos"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^(librephotos|librephotos-frontend|librephotos-db|librephotos-redis|librephotos-proxy)$' || true)
if [ -n "$EXISTING" ]; then
    warn "Stopping and removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
    info "Containers removed."
else
    info "No existing containers found."
fi
if [ -d "$SERVICE_DIR" ]; then
    warn "Removing existing configuration at $SERVICE_DIR..."
    rm -rf "$SERVICE_DIR"
    info "Configuration removed."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
mkdir -p "$SERVICE_DIR" "$SERVICE_DIR/db" "$SERVICE_DIR/photos" "$SERVICE_DIR/data"
cd "$SERVICE_DIR" || error "Cannot navigate to $SERVICE_DIR"
info "Directory ready: $SERVICE_DIR"

section "Step 6: Generating Configuration & docker-compose.yml"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 24)
SECRET_KEY=$(openssl rand -hex 32)
ADMIN_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 16)
info "Login: admin / $ADMIN_PASS"

cat > "$SERVICE_DIR/docker-compose.yml" <<EOF
services:
  librephotos-db:
    image: postgres:15-alpine
    container_name: librephotos-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: librephotos
      POSTGRES_USER: librephotos
      POSTGRES_PASSWORD: $DB_PASS
    volumes:
      - ./db:/var/lib/postgresql/data
    networks:
      - librephotos-net

  librephotos-redis:
    image: redis:7-alpine
    container_name: librephotos-redis
    restart: unless-stopped
    networks:
      - librephotos-net

  librephotos:
    image: reallibrephotos/librephotos:latest
    container_name: librephotos
    restart: unless-stopped
    depends_on:
      - librephotos-db
      - librephotos-redis
    environment:
      SECRET_KEY: $SECRET_KEY
      BACKEND_HOST: backend
      ADMIN_EMAIL: admin@example.com
      ADMIN_USERNAME: admin
      ADMIN_PASSWORD: $ADMIN_PASS
      DB_BACKEND: postgresql
      DB_NAME: librephotos
      DB_USER: librephotos
      DB_PASS: $DB_PASS
      DB_HOST: librephotos-db
      DB_PORT: 5432
      REDIS_HOST: librephotos-redis
      REDIS_PORT: 6379
      MAPBOX_API_KEY: ""
      WEB_CONCURRENCY: 1
    volumes:
      - ./photos:/data
      - ./data:/protected_media
    networks:
      librephotos-net:
        aliases:
          - backend

  librephotos-frontend:
    image: reallibrephotos/librephotos-frontend:latest
    container_name: librephotos-frontend
    restart: unless-stopped
    depends_on:
      - librephotos
    networks:
      librephotos-net:
        aliases:
          - frontend

  librephotos-proxy:
    image: reallibrephotos/librephotos-proxy:latest
    container_name: librephotos-proxy
    restart: unless-stopped
    depends_on:
      - librephotos
      - librephotos-frontend
    ports:
      - "3063:80"
    volumes:
      - ./photos:/data
      - ./data:/protected_media
    networks:
      - librephotos-net

networks:
  librephotos-net:
    driver: bridge
EOF
info "docker-compose.yml created."

section "Step 7: Starting LibrePhotos"
warn "LibrePhotos runs ML models — first start needs 4 GB+ RAM and several minutes."
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    docker compose up -d && break
    warn "Docker pull failed on attempt $attempt/$MAX_RETRIES."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed to start after $MAX_RETRIES attempts."
done

section "Step 8: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    ufw allow 3063/tcp
    info "UFW: required ports opened."
else
    warn "UFW not found — skipping firewall rules."
fi

section "Step 9: Verifying Containers"
sleep 10
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^librephotos$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs librephotos"
else
    info "Container running: $RUNNING"
fi

section "Step 10: Health Check"
info "Waiting for LibrePhotos to be ready on port 3063..."
HEALTH_OK=0
for i in $(seq 1 48); do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://127.0.0.1:3063 2>/dev/null || echo "000")
    if echo "$STATUS" | grep -qE '^(200|301|302|303|401)$'; then
        info "Port 3063 is responding (HTTP $STATUS) — LibrePhotos is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/48 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 3063 2>/dev/null; then
        warn "Port 3063 is open but HTTP did not respond. Service may still be starting."
    else
        warn "Port 3063 is NOT responding yet."
        docker logs --tail 20 librephotos 2>&1 || true
    fi
    warn "Check logs: docker logs librephotos"
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  📷  LibrePhotos:  http://$SERVER_IP:3063"
echo "  ║  🔑  Login: admin / $ADMIN_PASS"
echo "  ║  📁  Put photos in $SERVICE_DIR/photos"
echo "  ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️"
echo "  ║       Made by: Mohammed Ali Elshikh"
echo "  ║       prismatechwork.com"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║  🚀  Need production setup?                         ║"
echo "  ║      👨‍💻  Mohammed Ali Elshikh | prismatechwork.com"
echo "  ║  ☕  USDT (TRC-20): TCSZTkXvhibdrFre5sdTsFLRQ6d6yQkd2i"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
