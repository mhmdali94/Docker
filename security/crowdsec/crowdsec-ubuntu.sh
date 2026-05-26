#!/bin/bash
#
# ============================================================
#   CrowdSec Auto-Installer
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
echo "  ║          CrowdSec Auto-Installer                 ║"
echo "  ║          Made by: Mohammed Ali Elshikh          ║"
echo "  ║          prismatechwork.com                     ║"
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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^crowdsec$' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing CrowdSec containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
CS_DIR="/root/docker/crowdsec"
if [ -d "$CS_DIR" ]; then
    warn "Removing old directory $CS_DIR..."
    rm -rf "$CS_DIR"
fi
mkdir -p "$CS_DIR"
cd "$CS_DIR" || error "Cannot navigate to $CS_DIR"
info "Directory ready: $CS_DIR"

section "Step 6: Writing docker-compose.yml"
cat > "$CS_DIR/docker-compose.yml" <<'EOF'
services:
  crowdsec:
    image: crowdsecurity/crowdsec:latest
    container_name: crowdsec
    restart: unless-stopped
    ports:
      - "6060:6060"
      - "8181:8080"
    environment:
      GID: "1000"
      COLLECTIONS: "crowdsecurity/linux crowdsecurity/sshd crowdsecurity/nginx"
    volumes:
      - ./data:/var/lib/crowdsec/data
      - ./config:/etc/crowdsec
      - /var/log/auth.log:/var/log/auth.log:ro
      - /var/log/syslog:/var/log/syslog:ro
    cap_add:
      - NET_ADMIN
      - NET_RAW
EOF
info "docker-compose.yml created."

section "Step 7: Starting CrowdSec"
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
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^crowdsec$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs crowdsec"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for CrowdSec metrics on port 6060..."
HEALTH_OK=0
for i in $(seq 1 12); do
    if curl -s --max-time 3 http://127.0.0.1:6060/metrics &>/dev/null; then
        info "Port 6060 is responding — CrowdSec is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 6060 2>/dev/null; then
        warn "Port 6060 is open but not fully ready."
        warn "Check logs: docker logs crowdsec"
    else
        warn "Port 6060 is NOT responding after 60s."
        docker logs --tail 20 crowdsec 2>&1 || true
    fi
fi

info "Generating CrowdSec local API key..."
sleep 5
CS_API_KEY=$(docker exec crowdsec cscli bouncers add docker-bouncer -o raw 2>/dev/null || echo "Run manually: docker exec crowdsec cscli bouncers add my-bouncer")

section "Step 10: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    ufw allow 6060/tcp
    ufw allow 8181/tcp
    info "UFW: ports 6060 and 8181/tcp opened."
else
    warn "UFW not found — skipping firewall rules."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  📊  CrowdSec Metrics: http://$SERVER_IP:6060/metrics"
echo "  ║  🔌  Local API:        http://$SERVER_IP:8181"
echo "  ║                                                      ║"
echo "  ║  🔑  Bouncer API Key: $CS_API_KEY"
echo "  ║                                                      ║"
echo "  ║  🔎  View alerts:                                   ║"
echo "  ║      docker exec crowdsec cscli alerts list         ║"
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
