#!/bin/bash
#
# ============================================================
#   Pritunl Auto-Installer
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
echo "  ║       Pritunl Auto-Installer                     ║"
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
for cname in pritunl pritunl-mongo; do
    if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -qE "^${cname}$"; then
        warn "Removing existing container: $cname"
        docker rm -f "$cname" 2>/dev/null || true
    fi
done
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
PT_DIR="/root/docker/pritunl"
if [ -d "$PT_DIR" ]; then
    warn "Removing old directory $PT_DIR..."
    rm -rf "$PT_DIR"
fi
mkdir -p "$PT_DIR/mongo"
touch "$PT_DIR/pritunl.conf"
cd "$PT_DIR" || error "Cannot navigate to $PT_DIR"
info "Directory ready: $PT_DIR"

section "Step 6: Creating docker-compose.yml"
cat > "$PT_DIR/docker-compose.yml" <<EOF
services:
  pritunl-mongo:
    image: mongo:6
    container_name: pritunl-mongo
    restart: unless-stopped
    volumes:
      - ./mongo:/data/db
    healthcheck:
      test: echo 'db.runCommand("ping").ok' | mongosh localhost:27017/test --quiet
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 20s

  pritunl:
    image: goofball222/pritunl:latest
    container_name: pritunl
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "1194:1194/udp"
    volumes:
      - ./pritunl.conf:/etc/pritunl.conf
    environment:
      MONGODB_URI: mongodb://pritunl-mongo:27017/pritunl
    depends_on:
      pritunl-mongo:
        condition: service_healthy
    privileged: true
    sysctls:
      - net.ipv4.ip_forward=1
EOF
info "docker-compose.yml created."

section "Step 7: Starting Pritunl"
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    docker compose up -d && break
    warn "Docker pull failed on attempt $attempt/$MAX_RETRIES."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed to start after $MAX_RETRIES attempts."
done

section "Step 8: Verifying Container"
sleep 20
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^pritunl$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs pritunl"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Getting Default Credentials"
sleep 5
info "Retrieving default setup key..."
SETUP_KEY=$(docker exec pritunl pritunl setup-key 2>/dev/null || echo "Run: docker exec pritunl pritunl setup-key")
info "Setup Key : $SETUP_KEY"

section "Step 10: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw allow 1194/udp
    info "UFW: ports 80/tcp, 443/tcp, 1194/udp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Pritunl in your browser:                 ║"
echo "  ║      👉  https://$SERVER_IP                         ║"
echo "  ║                                                      ║"
echo "  ║  🔑  Setup Key: $SETUP_KEY"
echo "  ║                                                      ║"
echo "  ║  📋  After setup, get default password:            ║"
echo "  ║      docker exec pritunl pritunl default-password   ║"
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
