#!/bin/bash
#
# ============================================================
#   Gitea Self-Hosted Git Service Auto-Installer
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
echo "  ║       Gitea Self-Hosted Git Auto-Installer       ║"
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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E 'gitea' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing Gitea containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
GITEA_DIR="/root/docker/gitea"
if [ -d "$GITEA_DIR" ]; then
    warn "Removing old directory $GITEA_DIR..."
    rm -rf "$GITEA_DIR"
fi
mkdir -p "$GITEA_DIR"
cd "$GITEA_DIR" || error "Cannot navigate to $GITEA_DIR"
info "Directory ready: $GITEA_DIR"

section "Step 6: Generating Credentials & docker-compose.yml"
GITEA_DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 24)
info "Database password generated."

cat > "$GITEA_DIR/docker-compose.yml" <<EOF
services:
  gitea-db:
    image: postgres:15
    container_name: gitea-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: gitea
      POSTGRES_USER: gitea
      POSTGRES_PASSWORD: $GITEA_DB_PASS
    volumes:
      - ./pgdata:/var/lib/postgresql/data
    networks:
      - gitea-net

  gitea:
    image: gitea/gitea:latest
    container_name: gitea
    restart: unless-stopped
    depends_on:
      - gitea-db
    ports:
      - "3100:3000"
      - "2222:22"
    environment:
      USER_UID: 1000
      USER_GID: 1000
      GITEA__database__DB_TYPE: postgres
      GITEA__database__HOST: gitea-db:5432
      GITEA__database__NAME: gitea
      GITEA__database__USER: gitea
      GITEA__database__PASSWD: $GITEA_DB_PASS
    volumes:
      - ./data:/data
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
    networks:
      - gitea-net

networks:
  gitea-net:
    driver: bridge
EOF
info "docker-compose.yml created."

section "Step 7: Starting Gitea"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 8: Verifying Containers"
sleep 8
RUNNING=$(docker ps --format '{{.Names}}' | grep -E 'gitea' || true)
if [ -z "$RUNNING" ]; then
    warn "Containers may not have started. Check: docker logs gitea"
else
    info "Containers running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for Gitea to be ready on port 3100..."
HEALTH_OK=0
for i in $(seq 1 12); do
    if curl -sf --max-time 3 http://127.0.0.1:3100 &>/dev/null; then
        info "Port 3100 is responding — Gitea is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 3100 2>/dev/null; then
        warn "Port 3100 is open but HTTP did not respond. Service may still be starting."
        warn "Check logs: docker logs gitea"
    else
        warn "Port 3100 is NOT responding after 60s."
        warn "Check logs: docker logs gitea"
        docker logs --tail 20 gitea 2>&1 || true
    fi
fi

section "Step 10: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    ufw allow 3100/tcp
    ufw allow 2222/tcp
    info "UFW: ports 3100/tcp and 2222/tcp opened."
else
    warn "UFW not found — skipping firewall rules."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Gitea in your browser:                   ║"
echo "  ║      👉  http://$SERVER_IP:3100"
echo "  ║                                                      ║"
echo "  ║  🔑  Complete setup wizard on first visit.         ║"
echo "  ║                                                      ║"
echo "  ║  🔒  SSH Git access:                               ║"
echo "  ║      ssh://git@$SERVER_IP:2222"
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
