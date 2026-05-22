#!/bin/bash
#
# ============================================================
#   Infisical Auto-Installer
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
echo "  ║         Infisical Auto-Installer                 ║"
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
for cname in infisical infisical-db infisical-redis; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    if [ -n "$EXISTING" ]; then
        warn "Removing existing container: $cname"
        docker rm -f "$cname" 2>/dev/null || true
    fi
done
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
INFIS_DIR="/root/docker/infisical"
if [ -d "$INFIS_DIR" ]; then
    warn "Removing old directory $INFIS_DIR..."
    rm -rf "$INFIS_DIR"
fi
mkdir -p "$INFIS_DIR"
cd "$INFIS_DIR" || error "Cannot navigate to $INFIS_DIR"
info "Directory ready: $INFIS_DIR"

section "Step 6: Generating Credentials & docker-compose.yml"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
ENC_KEY=$(tr -dc 'a-f0-9' < /dev/urandom | head -c 32)
AUTH_SECRET=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)
info "Credentials generated."

cat > "$INFIS_DIR/docker-compose.yml" <<EOF
services:
  infisical-db:
    image: postgres:14
    container_name: infisical-db
    restart: unless-stopped
    environment:
      POSTGRES_USER: infisical
      POSTGRES_PASSWORD: $DB_PASS
      POSTGRES_DB: infisical
    volumes:
      - ./postgres:/var/lib/postgresql/data

  infisical-redis:
    image: redis:7
    container_name: infisical-redis
    restart: unless-stopped
    volumes:
      - ./redis:/data

  infisical:
    image: infisical/infisical:latest-postgres
    container_name: infisical
    restart: unless-stopped
    ports:
      - "8090:8080"
    environment:
      NODE_ENV: production
      ENCRYPTION_KEY: $ENC_KEY
      AUTH_SECRET: $AUTH_SECRET
      DB_CONNECTION_URI: postgres://infisical:$DB_PASS@infisical-db:5432/infisical
      REDIS_URL: redis://infisical-redis:6379
      SITE_URL: http://$SERVER_IP:8090
    depends_on:
      - infisical-db
      - infisical-redis
EOF
info "docker-compose.yml created."

section "Step 7: Starting Infisical"
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
sleep 8
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^infisical$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs infisical"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for Infisical to be ready on port 8090..."
HEALTH_OK=0
for i in $(seq 1 12); do
    if curl -sf --max-time 3 http://127.0.0.1:8090/api/status &>/dev/null; then
        info "Port 8090 is responding — Infisical is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 8090 2>/dev/null; then
        warn "Port 8090 is open but not fully ready."
        warn "Check logs: docker logs infisical"
    else
        warn "Port 8090 is NOT responding after 60s."
        docker logs --tail 20 infisical 2>&1 || true
    fi
fi

section "Step 10: Opening Firewall Port 8090"
if command -v ufw &> /dev/null; then
    ufw allow 8090/tcp
    info "UFW: port 8090/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Infisical in your browser:              ║"
echo "  ║      👉  http://$SERVER_IP:8090"
echo "  ║                                                      ║"
echo "  ║  🔑  Create your admin account on first visit.     ║"
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
