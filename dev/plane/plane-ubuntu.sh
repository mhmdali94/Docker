#!/bin/bash
#
# ============================================================
#   Plane Auto-Installer
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
echo "  ║           Plane Auto-Installer                   ║"
echo "  ║           Made by: Mohammed Ali Elshikh         ║"
echo "  ║           prismatechwork.com                    ║"
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
for cname in plane-proxy plane-web plane-api plane-worker plane-db plane-redis plane-minio; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    if [ -n "$EXISTING" ]; then
        warn "Removing existing container: $cname"
        docker rm -f "$cname" 2>/dev/null || true
    fi
done
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
PLANE_DIR="/root/docker/plane"
if [ -d "$PLANE_DIR" ]; then
    warn "Removing old directory $PLANE_DIR..."
    rm -rf "$PLANE_DIR"
fi
mkdir -p "$PLANE_DIR"
cd "$PLANE_DIR" || error "Cannot navigate to $PLANE_DIR"
info "Directory ready: $PLANE_DIR"

section "Step 6: Generating Credentials & docker-compose.yml"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
SECRET=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 50)
MINIO_USER=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 12)
MINIO_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
info "Credentials generated."

cat > "$PLANE_DIR/docker-compose.yml" <<EOF
services:
  plane-db:
    image: postgres:15
    container_name: plane-db
    restart: unless-stopped
    environment:
      POSTGRES_USER: plane
      POSTGRES_PASSWORD: $DB_PASS
      POSTGRES_DB: plane
    volumes:
      - ./postgres:/var/lib/postgresql/data

  plane-redis:
    image: redis:7
    container_name: plane-redis
    restart: unless-stopped
    volumes:
      - ./redis:/data

  plane-minio:
    image: minio/minio:latest
    container_name: plane-minio
    restart: unless-stopped
    command: server /data
    environment:
      MINIO_ROOT_USER: $MINIO_USER
      MINIO_ROOT_PASSWORD: $MINIO_PASS
    volumes:
      - ./minio:/data

  plane-api:
    image: makeplane/plane-backend:latest
    container_name: plane-api
    restart: unless-stopped
    command: ./bin/docker-entrypoint-api.sh
    environment:
      DJANGO_SETTINGS_MODULE: plane.settings.production
      DATABASE_URL: postgresql://plane:$DB_PASS@plane-db:5432/plane
      REDIS_URL: redis://plane-redis:6379/
      SECRET_KEY: $SECRET
      WEB_URL: http://$SERVER_IP:8091
      FILE_SIZE_LIMIT: 5242880
    depends_on:
      - plane-db
      - plane-redis

  plane-worker:
    image: makeplane/plane-backend:latest
    container_name: plane-worker
    restart: unless-stopped
    command: ./bin/docker-entrypoint-worker.sh
    environment:
      DATABASE_URL: postgresql://plane:$DB_PASS@plane-db:5432/plane
      REDIS_URL: redis://plane-redis:6379/
      SECRET_KEY: $SECRET
    depends_on:
      - plane-api

  plane-web:
    image: makeplane/plane-frontend:latest
    container_name: plane-web
    restart: unless-stopped
    environment:
      NEXT_PUBLIC_API_BASE_URL: http://$SERVER_IP:8091
    depends_on:
      - plane-api

  plane-proxy:
    image: makeplane/plane-proxy:latest
    container_name: plane-proxy
    restart: unless-stopped
    ports:
      - "8091:80"
    environment:
      NGINX_PORT: 80
    depends_on:
      - plane-web
      - plane-api
EOF
info "docker-compose.yml created."

section "Step 7: Starting Plane"
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    if docker compose version &> /dev/null; then
        docker compose up -d && break
    else
        docker-compose up -d && break
    fi
    warn "Docker pull failed on attempt $attempt/$MAX_RETRIES (registry may be temporarily unavailable)."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed to start after $MAX_RETRIES attempts. Run manually: cd $PWD && docker compose up -d"
done

section "Step 8: Verifying Container"
sleep 10
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^plane-proxy$' || true)
if [ -z "$RUNNING" ]; then
    warn "Plane proxy may not have started. Check: docker logs plane-proxy"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for Plane to be ready on port 8091..."
HEALTH_OK=0
for i in $(seq 1 18); do
    if curl -sf --max-time 5 http://127.0.0.1:8091 &>/dev/null; then
        info "Port 8091 is responding — Plane is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/18 — waiting 10s..."
    sleep 10
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 8091 2>/dev/null; then
        warn "Port 8091 is open but Plane may still be initializing."
        warn "Check logs: docker logs plane-api"
    else
        warn "Port 8091 is NOT responding."
        docker logs --tail 20 plane-api 2>&1 || true
    fi
fi

section "Step 10: Opening Firewall Port 8091"
if command -v ufw &> /dev/null; then
    ufw allow 8091/tcp
    info "UFW: port 8091/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Plane in your browser:                  ║"
echo "  ║      👉  http://$SERVER_IP:8091"
echo "  ║                                                      ║"
echo "  ║  🔑  Create your workspace on first visit.         ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║                                                      ║"
echo "  ║  🚀  Need a production-ready setup?                 ║"
echo "  ║                                                      ║"
echo "  ║  Contact us for a hardened, secure, and             ║"
echo "  ║  fully configured production environment:           ║"
echo "  ║                                                      ║"
echo "  ║  👨‍💻  Mohammed Ali Elshikh                            ║"
echo "  ║  🌐  prismatechwork.com                              ║"
echo "  ║                                                      ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
