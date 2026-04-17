#!/bin/bash
#
# ============================================================
#   Grafana Dashboard Auto-Installer
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
echo "  ║       Grafana Dashboard Auto-Installer           ║"
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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^grafana$' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing Grafana containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
GRAFANA_DIR="/root/docker/grafana"
if [ -d "$GRAFANA_DIR" ]; then
    warn "Removing old directory $GRAFANA_DIR..."
    rm -rf "$GRAFANA_DIR"
fi
mkdir -p "$GRAFANA_DIR/data" "$GRAFANA_DIR/provisioning"
chown -R 472:472 "$GRAFANA_DIR/data"
cd "$GRAFANA_DIR" || error "Cannot navigate to $GRAFANA_DIR"
info "Directory ready: $GRAFANA_DIR"

section "Step 6: Generating Credentials & docker-compose.yml"
GF_PASSWORD=$(tr -dc 'A-Za-z0-9!@#$%' < /dev/urandom | head -c 20)
info "Admin User     : admin"
info "Admin Password : $GF_PASSWORD"

cat > "$GRAFANA_DIR/docker-compose.yml" <<EOF
services:
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      GF_SECURITY_ADMIN_USER: admin
      GF_SECURITY_ADMIN_PASSWORD: $GF_PASSWORD
      GF_USERS_ALLOW_SIGN_UP: "false"
    volumes:
      - ./data:/var/lib/grafana
      - ./provisioning:/etc/grafana/provisioning
EOF
info "docker-compose.yml created."

section "Step 7: Starting Grafana"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 8: Verifying Container"
sleep 5
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^grafana$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs grafana"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for Grafana to be ready on port 3000..."
HEALTH_OK=0
for i in $(seq 1 12); do
    if curl -sf --max-time 3 http://127.0.0.1:3000/api/health &>/dev/null; then
        info "Port 3000 is responding — Grafana is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 3000 2>/dev/null; then
        warn "Port 3000 is open but /api/health did not respond. Service may still be starting."
        warn "Check logs: docker logs grafana"
    else
        warn "Port 3000 is NOT responding after 60s."
        warn "Check logs: docker logs grafana"
        docker logs --tail 20 grafana 2>&1 || true
    fi
fi

section "Step 10: Opening Firewall Port 3000"
if command -v ufw &> /dev/null; then
    ufw allow 3000/tcp
    info "UFW: port 3000/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Grafana in your browser:                 ║"
echo "  ║      👉  http://$SERVER_IP:3000"
echo "  ║                                                      ║"
echo "  ║  🔑  Login Credentials (save these!):              ║"
echo "  ║      Username : admin"
echo "  ║      Password : $GF_PASSWORD"
echo "  ║                                                      ║"
echo "  ║  📊  Add data sources under:                       ║"
echo "  ║      Configuration → Data Sources                   ║"
echo "  ║      (Prometheus, InfluxDB, Loki, etc.)             ║"
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
