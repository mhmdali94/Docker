#!/bin/bash
#
# ============================================================
#   Authentik Identity Provider Auto-Installer
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
echo "  ║       Authentik Identity Provider Installer      ║"
echo "  ║       Made by: Mohammed Ali Elshikh | prismatechwork.com                ║"
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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E 'authentik' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing Authentik containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
AK_DIR="/root/docker/authentik"
if [ -d "$AK_DIR" ]; then
    warn "Removing old directory $AK_DIR..."
    rm -rf "$AK_DIR"
fi
mkdir -p "$AK_DIR/media" "$AK_DIR/custom-templates" "$AK_DIR/certs"
cd "$AK_DIR" || error "Cannot navigate to $AK_DIR"
info "Directory ready: $AK_DIR"

section "Step 6: Generating Credentials & docker-compose.yml"
AK_DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)
AK_SECRET=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 50)
info "Credentials generated."
info "Set your admin password at first login via the web UI."

cat > "$AK_DIR/docker-compose.yml" <<EOF
services:
  authentik-db:
    image: postgres:16-alpine
    container_name: authentik-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: authentik
      POSTGRES_USER: authentik
      POSTGRES_PASSWORD: $AK_DB_PASS
    volumes:
      - ./pgdata:/var/lib/postgresql/data
    networks:
      - authentik-net

  authentik-redis:
    image: redis:alpine
    container_name: authentik-redis
    restart: unless-stopped
    command: --save 60 1 --loglevel warning
    volumes:
      - ./redis-data:/data
    networks:
      - authentik-net

  authentik-server:
    image: ghcr.io/goauthentik/server:latest
    container_name: authentik-server
    restart: unless-stopped
    command: server
    depends_on:
      - authentik-db
      - authentik-redis
    ports:
      - "9010:9000"
      - "9443:9443"
    environment:
      AUTHENTIK_REDIS__HOST: authentik-redis
      AUTHENTIK_POSTGRESQL__HOST: authentik-db
      AUTHENTIK_POSTGRESQL__USER: authentik
      AUTHENTIK_POSTGRESQL__NAME: authentik
      AUTHENTIK_POSTGRESQL__PASSWORD: $AK_DB_PASS
      AUTHENTIK_SECRET_KEY: $AK_SECRET
    volumes:
      - ./media:/media
      - ./custom-templates:/templates
      - ./certs:/certs
    networks:
      - authentik-net

  authentik-worker:
    image: ghcr.io/goauthentik/server:latest
    container_name: authentik-worker
    restart: unless-stopped
    command: worker
    depends_on:
      - authentik-db
      - authentik-redis
    environment:
      AUTHENTIK_REDIS__HOST: authentik-redis
      AUTHENTIK_POSTGRESQL__HOST: authentik-db
      AUTHENTIK_POSTGRESQL__USER: authentik
      AUTHENTIK_POSTGRESQL__NAME: authentik
      AUTHENTIK_POSTGRESQL__PASSWORD: $AK_DB_PASS
      AUTHENTIK_SECRET_KEY: $AK_SECRET
    volumes:
      - ./media:/media
      - ./certs:/certs
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - authentik-net

networks:
  authentik-net:
    driver: bridge
EOF
info "docker-compose.yml created."

section "Step 7: Starting Authentik"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 8: Verifying Containers"
sleep 10
RUNNING=$(docker ps --format '{{.Names}}' | grep -E 'authentik' || true)
if [ -z "$RUNNING" ]; then
    warn "Containers may not have started. Check: docker logs authentik-server"
else
    info "Containers running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for Authentik to be ready on port 9010 (may take a few minutes)..."
HEALTH_OK=0
for i in $(seq 1 24); do
    if curl -sf --max-time 5 http://127.0.0.1:9010/-/health/live/ &>/dev/null; then
        info "Port 9010 is responding — Authentik is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/24 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 9010 2>/dev/null; then
        warn "Port 9010 is open but health check did not respond. Still initializing."
        warn "Check logs: docker logs authentik-server"
    else
        warn "Port 9010 is NOT responding after 120s."
        warn "Check logs: docker logs authentik-server"
        docker logs --tail 20 authentik-server 2>&1 || true
    fi
fi

section "Step 10: Opening Firewall Port 9010"
if command -v ufw &> /dev/null; then
    ufw allow 9010/tcp
    ufw allow 9443/tcp
    info "UFW: ports 9010/tcp and 9443/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Authentik in your browser:               ║"
echo "  ║      👉  http://$SERVER_IP:9010/if/flow/initial-setup/"
echo "  ║                                                      ║"
echo "  ║  🔑  Complete the initial setup wizard to          ║"
echo "  ║      create your admin account.                     ║"
echo "  ║                                                      ║"
echo "  ║  🔒  HTTPS also available on port 9443             ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh | prismatechwork.com                   ║"
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
