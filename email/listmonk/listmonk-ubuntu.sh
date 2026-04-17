#!/bin/bash
#
# ============================================================
#   Listmonk Newsletter & Mailing List Auto-Installer
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
echo "  ║       Listmonk Newsletter Auto-Installer         ║"
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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^listmonk' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
LM_DIR="/root/docker/listmonk"
if [ -d "$LM_DIR" ]; then
    warn "Removing old directory $LM_DIR..."
    rm -rf "$LM_DIR"
fi
mkdir -p "$LM_DIR"
cd "$LM_DIR" || error "Cannot navigate to $LM_DIR"
info "Directory ready: $LM_DIR"

section "Step 6: Generating Credentials"
DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 24)
ADMIN_USER="admin"
ADMIN_PASS=$(tr -dc 'A-Za-z0-9!@#$%' < /dev/urandom | head -c 20)
info "Credentials generated."

section "Step 7: Generating Config & docker-compose.yml"
cat > "$LM_DIR/config.toml" <<EOF
[app]
address = "0.0.0.0:9000"
admin_username = "$ADMIN_USER"
admin_password = "$ADMIN_PASS"

[db]
host = "listmonk-db"
port = 5432
user = "listmonk"
password = "$DB_PASS"
database = "listmonk"
ssl_mode = "disable"
max_open = 25
max_idle = 25
max_lifetime = "300s"
EOF

cat > "$LM_DIR/docker-compose.yml" <<EOF
services:
  listmonk-db:
    image: postgres:15-alpine
    container_name: listmonk-db
    restart: unless-stopped
    volumes:
      - ./pgdata:/var/lib/postgresql/data
    environment:
      - POSTGRES_USER=listmonk
      - POSTGRES_PASSWORD=$DB_PASS
      - POSTGRES_DB=listmonk
    networks:
      - listmonk-net

  listmonk:
    image: listmonk/listmonk:latest
    container_name: listmonk
    restart: unless-stopped
    ports:
      - "9000:9000"
    volumes:
      - ./config.toml:/listmonk/config.toml
      - ./uploads:/listmonk/uploads
    command: [sh, -c, "yes | ./listmonk --install --config config.toml && ./listmonk --config config.toml"]
    depends_on:
      - listmonk-db
    networks:
      - listmonk-net

networks:
  listmonk-net:
    driver: bridge
EOF
info "Config and docker-compose.yml created."

section "Step 8: Starting Listmonk"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 9: Verifying Containers"
sleep 8
RUNNING=$(docker ps --format '{{.Names}}' | grep -E 'listmonk' || true)
if [ -z "$RUNNING" ]; then
    warn "Containers may not have started. Check: docker logs listmonk"
else
    info "Containers running: $RUNNING"
fi

section "Step 10: Health Check"
info "Waiting for Listmonk to be ready on port 9000..."
HEALTH_OK=0
for i in $(seq 1 12); do
    if curl -sf --max-time 3 http://127.0.0.1:9000 &>/dev/null; then
        info "Port 9000 is responding — Listmonk is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 9000 2>/dev/null; then
        warn "Port 9000 is open but HTTP did not respond. Service may still be starting."
        warn "Check logs: docker logs listmonk"
    else
        warn "Port 9000 is NOT responding after 60s."
        warn "Check logs: docker logs listmonk"
        docker logs --tail 20 listmonk 2>&1 || true
    fi
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Listmonk in your browser:                ║"
echo "  ║      👉  http://$SERVER_IP:9000"
echo "  ║                                                      ║"
echo "  ║  🔑  Login Credentials (save these!):              ║"
echo "  ║      Username : $ADMIN_USER"
echo "  ║      Password : $ADMIN_PASS"
echo "  ║                                                      ║"
echo "  ║  📧  Features:                                      ║"
echo "  ║      • Mailing lists & newsletters                  ║"
echo "  ║      • Subscriber management                        ║"
echo "  ║      • Campaign analytics                           ║"
echo "  ║      • Transactional emails                         ║"
echo "  ║      • Supports SMTP / AWS SES / Postmark           ║"
echo "  ║                                                      ║"
echo "  ║  ⚙️   Configure your SMTP under Settings → SMTP    ║"
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
