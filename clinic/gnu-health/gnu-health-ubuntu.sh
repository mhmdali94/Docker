#!/bin/bash
#
# ============================================================
#   GNU Health Auto-Installer
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
echo "  ║         GNU Health Auto-Installer                ║"
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
echo "  ║  GNU Health runs on the Tryton platform.            ║"
echo "  ║  Access via Tryton Web Client on port 8123.         ║"
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
for C in gnuhealth gnuhealth-db gnuhealth-web; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${C}$" || true)
    if [ -n "$EXISTING" ]; then
        warn "Removing existing container: $C"
        docker rm -f "$C" 2>/dev/null || true
    fi
done
if docker image inspect gnuhealth-local &>/dev/null; then
    warn "Removing existing gnuhealth-local image..."
    docker rmi -f gnuhealth-local 2>/dev/null || true
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
GH_DIR="/root/docker/gnu-health"
if [ -d "$GH_DIR" ]; then
    warn "Removing old directory $GH_DIR..."
    rm -rf "$GH_DIR"
fi
mkdir -p "$GH_DIR/data"
cd "$GH_DIR" || error "Cannot navigate to $GH_DIR"
info "Directory ready: $GH_DIR"

section "Step 6: Generating Credentials, Dockerfile & docker-compose.yml"
DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
ADMIN_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
info "Admin Password : $ADMIN_PASS"
info "Web UI / RPC Port : 8123"

cat > "$GH_DIR/Dockerfile" <<'DOCKERFILE'
FROM tryton/tryton:7.0
USER root
RUN pip3 install --no-cache-dir gnuhealth || \
    pip3 install --no-cache-dir --break-system-packages gnuhealth
USER trytond
DOCKERFILE

cat > "$GH_DIR/docker-compose.yml" <<EOF
services:
  gnuhealth-db:
    image: postgres:16
    container_name: gnuhealth-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: gnuhealth
      POSTGRES_PASSWORD: $DB_PASS
    volumes:
      - ./db:/var/lib/postgresql/data
    networks:
      - gnuhealth-net

  gnuhealth:
    image: gnuhealth-local
    container_name: gnuhealth
    restart: unless-stopped
    depends_on:
      - gnuhealth-db
    ports:
      - "8123:8000"
    environment:
      DB_HOSTNAME: gnuhealth-db
      DB_PASSWORD: $DB_PASS
    volumes:
      - ./data:/var/lib/trytond/db
    command:
      - /bin/bash
      - -c
      - |
        (until echo > /dev/tcp/gnuhealth-db/5432; do sleep 0.5; done) 2>/dev/null
        echo "$ADMIN_PASS" > /tmp/.passwd
        TRYTONPASSFILE=/tmp/.passwd /entrypoint.sh trytond-admin -d gnuhealth --all --email admin@gnuhealth.local -vv
        TRYTONPASSFILE=/tmp/.passwd /entrypoint.sh trytond-admin -d gnuhealth -u health --activate-dependencies || true
        if command -v uwsgi &>/dev/null; then uwsgi --ini /etc/uwsgi.conf; else gunicorn --config=/etc/gunicorn.conf.py; fi
    networks:
      - gnuhealth-net

networks:
  gnuhealth-net:
    driver: bridge
EOF
info "Dockerfile and docker-compose.yml created."

section "Step 7: Building & Starting GNU Health"
info "Building local image (tryton/tryton 7.0 + GNU Health modules) — takes several minutes..."
docker build --no-cache -t gnuhealth-local "$GH_DIR" || error "Docker build failed."
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
sleep 15
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^gnuhealth$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs gnuhealth"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for GNU Health to initialize (first run sets up the database — may take 5+ min)..."
HEALTH_OK=0
for i in $(seq 1 36); do
    if curl -s --max-time 5 http://127.0.0.1:8123 &>/dev/null; then
        info "Port 8123 is responding — GNU Health web client is ready. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/36 — waiting 10s..."
    sleep 10
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    warn "GNU Health may still be starting. Check: docker logs gnuhealth"
fi

section "Step 10: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    ufw allow 8123/tcp
    info "UFW: port 8123/tcp opened."
else
    warn "UFW not found — skipping firewall rules."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  GNU Health Web Client:                        ║"
echo "  ║      http://$SERVER_IP:8123"
echo "  ║                                                      ║"
echo "  ║  🔌  Tryton Server (for desktop client):           ║"
echo "  ║      Host: $SERVER_IP   Port: 8123"
echo "  ║                                                      ║"
echo "  ║  🔑  Login Credentials (save these!):              ║"
echo "  ║      Database : gnuhealth"
echo "  ║      Username : admin"
echo "  ║      Password : $ADMIN_PASS"
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
