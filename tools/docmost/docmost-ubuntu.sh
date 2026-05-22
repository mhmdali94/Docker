#!/bin/bash
#
# ============================================================
#   Docmost Auto-Installer
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
echo "  ║         Docmost Auto-Installer                   ║"
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
for cname in docmost docmost-db docmost-redis; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    if [ -n "$EXISTING" ]; then
        warn "Removing existing container: $cname"
        docker rm -f "$cname" 2>/dev/null || true
    fi
done
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
DM_DIR="/root/docker/docmost"
if [ -d "$DM_DIR" ]; then
    warn "Removing old directory $DM_DIR..."
    rm -rf "$DM_DIR"
fi
mkdir -p "$DM_DIR"
cd "$DM_DIR" || error "Cannot navigate to $DM_DIR"
info "Directory ready: $DM_DIR"

section "Step 6: Generating Credentials & docker-compose.yml"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
SECRET=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)
info "Register your account on first launch at http://$SERVER_IP:3004"

cat > "$DM_DIR/docker-compose.yml" <<EOF
services:
  docmost-db:
    image: postgres:16
    container_name: docmost-db
    restart: unless-stopped
    environment:
      POSTGRES_USER: docmost
      POSTGRES_PASSWORD: $DB_PASS
      POSTGRES_DB: docmost
    volumes:
      - ./postgres:/var/lib/postgresql/data

  docmost-redis:
    image: redis:7
    container_name: docmost-redis
    restart: unless-stopped
    volumes:
      - ./redis:/data

  docmost:
    image: docmost/docmost:latest
    container_name: docmost
    restart: unless-stopped
    ports:
      - "3004:3000"
    environment:
      APP_URL: http://$SERVER_IP:3004
      APP_SECRET: $SECRET
      DATABASE_URL: postgresql://docmost:$DB_PASS@docmost-db:5432/docmost
      REDIS_URL: redis://docmost-redis:6379
    volumes:
      - ./storage:/app/data/storage
    depends_on:
      - docmost-db
      - docmost-redis
EOF
info "docker-compose.yml created."

section "Step 7: Starting Docmost"
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
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^docmost$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs docmost"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for Docmost to be ready on port 3004..."
HEALTH_OK=0
for i in $(seq 1 12); do
    if curl -sf --max-time 5 http://127.0.0.1:3004 &>/dev/null; then
        info "Port 3004 is responding — Docmost is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 10s..."
    sleep 10
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    warn "Docmost may still be initializing. Check: docker logs docmost"
fi

section "Step 10: Opening Firewall Port 3004"
if command -v ufw &> /dev/null; then
    ufw allow 3004/tcp
    info "UFW: port 3004/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Docmost in your browser:               ║"
echo "  ║      👉  http://$SERVER_IP:3004"
echo "  ║                                                      ║"
echo "  ║  🔑  Register your admin account on first visit.   ║"
echo "  ║      The setup wizard will guide you through it.   ║"
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
