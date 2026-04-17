#!/bin/bash
#
# ============================================================
#   Prometheus Metrics Auto-Installer
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
echo "  ║       Prometheus Metrics Auto-Installer          ║"
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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^prometheus$' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing Prometheus containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
PROM_DIR="/root/docker/prometheus"
if [ -d "$PROM_DIR" ]; then
    warn "Removing old directory $PROM_DIR..."
    rm -rf "$PROM_DIR"
fi
mkdir -p "$PROM_DIR/data" "$PROM_DIR/config"
cd "$PROM_DIR" || error "Cannot navigate to $PROM_DIR"
info "Directory ready: $PROM_DIR"

section "Step 6: Generating Config & docker-compose.yml"
SERVER_IP_SETUP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)

cat > "$PROM_DIR/config/prometheus.yml" <<EOF
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "node"
    static_configs:
      - targets: ["$SERVER_IP_SETUP:9100"]
EOF

cat > "$PROM_DIR/docker-compose.yml" <<EOF
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: unless-stopped
    ports:
      - "9090:9090"
    volumes:
      - ./config/prometheus.yml:/etc/prometheus/prometheus.yml
      - ./data:/prometheus
    command:
      - "--config.file=/etc/prometheus/prometheus.yml"
      - "--storage.tsdb.path=/prometheus"
      - "--web.enable-lifecycle"
EOF
info "Config and docker-compose.yml created."

section "Step 7: Starting Prometheus"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 8: Verifying Container"
sleep 4
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^prometheus$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs prometheus"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for Prometheus to be ready on port 9090..."
HEALTH_OK=0
for i in $(seq 1 12); do
    if curl -sf --max-time 3 http://127.0.0.1:9090/-/healthy &>/dev/null; then
        info "Port 9090 is responding — Prometheus is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 9090 2>/dev/null; then
        warn "Port 9090 is open but /-/healthy did not respond. Service may still be starting."
        warn "Check logs: docker logs prometheus"
    else
        warn "Port 9090 is NOT responding after 60s."
        warn "Check logs: docker logs prometheus"
        docker logs --tail 20 prometheus 2>&1 || true
    fi
fi

section "Step 10: Opening Firewall Port 9090"
if command -v ufw &> /dev/null; then
    ufw allow 9090/tcp
    info "UFW: port 9090/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Prometheus in your browser:              ║"
echo "  ║      👉  http://$SERVER_IP:9090"
echo "  ║                                                      ║"
echo "  ║  📊  Query metrics at:                             ║"
echo "  ║      http://$SERVER_IP:9090/graph"
echo "  ║                                                      ║"
echo "  ║  ⚙️   Config file: $PROM_DIR/config/prometheus.yml  ║"
echo "  ║                                                      ║"
echo "  ║  💡  Pairs perfectly with Grafana for dashboards   ║"
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
