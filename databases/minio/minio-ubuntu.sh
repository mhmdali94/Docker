#!/bin/bash
#
# ============================================================
#   MinIO Object Storage Auto-Installer
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
echo "  ║       MinIO Object Storage Auto-Installer        ║"
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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^minio$' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing MinIO containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
MINIO_DIR="/root/docker/minio"
if [ -d "$MINIO_DIR" ]; then
    warn "Removing old directory $MINIO_DIR..."
    rm -rf "$MINIO_DIR"
fi
mkdir -p "$MINIO_DIR/data"
cd "$MINIO_DIR" || error "Cannot navigate to $MINIO_DIR"
info "Directory ready: $MINIO_DIR"

section "Step 6: Generating Credentials & docker-compose.yml"
MINIO_USER="minioadmin"
MINIO_PASSWORD=$(tr -dc 'A-Za-z0-9!@#$%' < /dev/urandom | head -c 24)
info "MinIO Root User     : $MINIO_USER"
info "MinIO Root Password : $MINIO_PASSWORD"

cat > "$MINIO_DIR/docker-compose.yml" <<EOF
services:
  minio:
    image: minio/minio:latest
    container_name: minio
    restart: unless-stopped
    ports:
      - "9000:9000"
      - "9001:9001"
    environment:
      MINIO_ROOT_USER: $MINIO_USER
      MINIO_ROOT_PASSWORD: $MINIO_PASSWORD
    volumes:
      - ./data:/data
    command: server /data --console-address ":9001"
EOF
info "docker-compose.yml created."

section "Step 7: Starting MinIO"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 8: Verifying Container"
sleep 4
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^minio$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs minio"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for MinIO to be ready on port 9000..."
HEALTH_OK=0
for i in $(seq 1 12); do
    if curl -sf --max-time 3 http://127.0.0.1:9000/minio/health/live &>/dev/null; then
        info "Port 9000 is responding — MinIO is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 9000 2>/dev/null; then
        warn "Port 9000 is open but health endpoint did not respond. Service may still be starting."
        warn "Check logs: docker logs minio"
    else
        warn "Port 9000 is NOT responding after 60s."
        warn "Check logs: docker logs minio"
        docker logs --tail 20 minio 2>&1 || true
    fi
fi

section "Step 10: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    ufw allow 9000/tcp
    ufw allow 9001/tcp
    info "UFW: ports 9000/9001 opened."
else
    warn "UFW not found — skipping firewall rule."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open MinIO Console in your browser:           ║"
echo "  ║      👉  http://$SERVER_IP:9001"
echo "  ║                                                      ║"
echo "  ║  🔑  Login Credentials (save these!):              ║"
echo "  ║      User     : $MINIO_USER"
echo "  ║      Password : $MINIO_PASSWORD"
echo "  ║                                                      ║"
echo "  ║  📦  S3 API Endpoint: http://$SERVER_IP:9000"
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
