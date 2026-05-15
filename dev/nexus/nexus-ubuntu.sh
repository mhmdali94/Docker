#!/bin/bash
#
# ============================================================
#   Nexus Repository Manager Auto-Installer
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
echo "  ║    Nexus Repository Manager Auto-Installer       ║"
echo "  ║    Made by: Mohammed Ali Elshikh                ║"
echo "  ║    prismatechwork.com                           ║"
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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^nexus$' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing Nexus containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
NEXUS_DIR="/root/docker/nexus"
if [ -d "$NEXUS_DIR" ]; then
    warn "Removing old directory $NEXUS_DIR..."
    rm -rf "$NEXUS_DIR"
fi
mkdir -p "$NEXUS_DIR/data"
chown -R 200:200 "$NEXUS_DIR/data"
cd "$NEXUS_DIR" || error "Cannot navigate to $NEXUS_DIR"
info "Directory ready: $NEXUS_DIR"

section "Step 6: Writing docker-compose.yml"
cat > "$NEXUS_DIR/docker-compose.yml" <<'EOF'
services:
  nexus:
    image: sonatype/nexus3:latest
    container_name: nexus
    restart: unless-stopped
    ports:
      - "8081:8081"
    volumes:
      - ./data:/nexus-data
    ulimits:
      nofile:
        soft: 65536
        hard: 65536
EOF
info "docker-compose.yml created."

section "Step 7: Starting Nexus Repository Manager"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 8: Verifying Container"
sleep 8
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^nexus$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs nexus"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for Nexus to be ready on port 8081 (may take ~2 minutes)..."
HEALTH_OK=0
for i in $(seq 1 24); do
    if curl -sf --max-time 5 http://127.0.0.1:8081/service/rest/v1/status &>/dev/null; then
        info "Port 8081 is responding — Nexus is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/24 — waiting 10s..."
    sleep 10
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 8081 2>/dev/null; then
        warn "Port 8081 is open but Nexus may still be initializing."
        warn "Check logs: docker logs nexus"
    else
        warn "Port 8081 is NOT responding."
        docker logs --tail 20 nexus 2>&1 || true
    fi
fi

info "Retrieving initial admin password..."
NEXUS_PASS="not yet available"
for i in $(seq 1 12); do
    if [ -f "$NEXUS_DIR/data/admin.password" ]; then
        NEXUS_PASS=$(cat "$NEXUS_DIR/data/admin.password")
        info "Initial admin password retrieved. ✅"
        break
    fi
    sleep 5
done

section "Step 10: Opening Firewall Port 8081"
if command -v ufw &> /dev/null; then
    ufw allow 8081/tcp
    info "UFW: port 8081/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Nexus in your browser:                  ║"
echo "  ║      👉  http://$SERVER_IP:8081"
echo "  ║                                                      ║"
echo "  ║  🔑  Login Credentials:                            ║"
echo "  ║      Username : admin"
echo "  ║      Password : $NEXUS_PASS"
echo "  ║                                                      ║"
echo "  ║  📁  Password file: $NEXUS_DIR/data/admin.password"
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
