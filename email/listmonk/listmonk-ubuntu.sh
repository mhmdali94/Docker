#!/bin/bash
#
# ============================================================
#   Listmonk Auto-Installer
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
echo "  ║       Listmonk Auto-Installer                    ║"
echo "  ║       Made by: Mohammed Ali Elshikh             ║"
echo "  ║       prismatechwork.com                        ║"
echo "  ║                                                  ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️         ║"
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

section "Step 4: Cleaning Up Existing Containers"
for cname in listmonk listmonk-db; do
    if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -qE "^${cname}$"; then
        warn "Removing existing container: $cname"
        docker rm -f "$cname" 2>/dev/null || true
    fi
done
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
LM_DIR="/root/docker/listmonk"
if [ -d "$LM_DIR" ]; then
    warn "Removing old directory $LM_DIR..."
    rm -rf "$LM_DIR"
fi
mkdir -p "$LM_DIR/postgres"
chown -R 999:999 "$LM_DIR/postgres"
cd "$LM_DIR" || error "Cannot navigate to $LM_DIR"
info "Directory ready: $LM_DIR"

section "Step 6: Generating Credentials & docker-compose.yml"
DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
ADMIN_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
info "Admin User     : admin"
info "Admin Password : $ADMIN_PASS"

cat > "$LM_DIR/docker-compose.yml" <<EOF
services:
  listmonk-db:
    image: postgres:15
    container_name: listmonk-db
    restart: unless-stopped
    environment:
      POSTGRES_USER: listmonk
      POSTGRES_PASSWORD: $DB_PASS
      POSTGRES_DB: listmonk
    volumes:
      - ./postgres:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U listmonk -d listmonk"]
      interval: 5s
      timeout: 5s
      retries: 10

  listmonk:
    image: listmonk/listmonk:latest
    container_name: listmonk
    restart: unless-stopped
    ports:
      - "9000:9000"
    environment:
      LISTMONK_db__host: listmonk-db
      LISTMONK_db__port: 5432
      LISTMONK_db__user: listmonk
      LISTMONK_db__password: $DB_PASS
      LISTMONK_db__database: listmonk
      LISTMONK_db__ssl_mode: disable
      LISTMONK_app__admin_username: admin
      LISTMONK_app__admin_password: $ADMIN_PASS
    depends_on:
      listmonk-db:
        condition: service_healthy
    command: [sh, -c, "yes | ./listmonk --install --idempotent && ./listmonk"]
EOF
info "docker-compose.yml created."

section "Step 7: Starting Listmonk"
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    docker compose up -d && break
    warn "Docker pull failed on attempt $attempt/$MAX_RETRIES."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed to start after $MAX_RETRIES attempts."
done

section "Step 8: Verifying Container"
sleep 15
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^listmonk$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs listmonk"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for Listmonk to be ready on port 9000..."
HEALTH_OK=0
for i in $(seq 1 12); do
    if curl -s --max-time 5 http://127.0.0.1:9000 &>/dev/null; then
        info "Port 9000 is responding — Listmonk is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done
[ "$HEALTH_OK" -eq 0 ] && warn "Listmonk may still be initializing. Check: docker logs listmonk"

section "Step 10: Opening Firewall Port 9000"
if command -v ufw &> /dev/null; then
    ufw allow 9000/tcp
    info "UFW: port 9000/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Listmonk in your browser:                ║"
echo "  ║      👉  http://$SERVER_IP:9000                     ║"
echo "  ║                                                      ║"
echo "  ║  🔑  Login Credentials (save these!):              ║"
echo "  ║      Username : admin                               ║"
echo "  ║      Password : $ADMIN_PASS                         ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║  🚀  Need production setup?                         ║"
echo "  ║      👨‍💻  Mohammed Ali Elshikh | prismatechwork.com  ║"
echo "  ║  ☕  USDT TRC-20: TCSZTkXvhibdrFre5sdTsFLRQ6d6yQkd2i ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
