#!/bin/bash
#
# ============================================================
#   SigNoz Auto-Installer
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
echo "  ║          SigNoz Auto-Installer                   ║"
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
for cname in signoz-clickhouse signoz-query signoz-frontend; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    if [ -n "$EXISTING" ]; then
        warn "Removing existing container: $cname"
        docker rm -f "$cname" 2>/dev/null || true
    fi
done
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
SIGNOZ_DIR="/root/docker/signoz"
if [ -d "$SIGNOZ_DIR" ]; then
    warn "Removing old directory $SIGNOZ_DIR..."
    rm -rf "$SIGNOZ_DIR"
fi
mkdir -p "$SIGNOZ_DIR"
cd "$SIGNOZ_DIR" || error "Cannot navigate to $SIGNOZ_DIR"
info "Directory ready: $SIGNOZ_DIR"

section "Step 6: Generating Credentials & docker-compose.yml"
CH_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
info "ClickHouse password generated."

sysctl -w vm.max_map_count=262144
info "vm.max_map_count set (required for ClickHouse)."

cat > "$SIGNOZ_DIR/docker-compose.yml" <<EOF
services:
  signoz-clickhouse:
    image: clickhouse/clickhouse-server:23.8
    container_name: signoz-clickhouse
    restart: unless-stopped
    environment:
      CLICKHOUSE_DB: signoz_traces
      CLICKHOUSE_USER: admin
      CLICKHOUSE_PASSWORD: $CH_PASS
      CLICKHOUSE_DEFAULT_ACCESS_MANAGEMENT: 1
    volumes:
      - ./clickhouse:/var/lib/clickhouse
    ulimits:
      nofile:
        soft: 262144
        hard: 262144

  signoz-query:
    image: signoz/query-service:latest
    container_name: signoz-query
    restart: unless-stopped
    ports:
      - "8080:8080"
      - "4317:4317"
      - "4318:4318"
    environment:
      ClickHouseUrl: tcp://signoz-clickhouse:9000/?database=signoz_traces&username=admin&password=$CH_PASS
      STORAGE: clickhouse
      GODEBUG: netdns=go
    depends_on:
      - signoz-clickhouse

  signoz-frontend:
    image: signoz/frontend:latest
    container_name: signoz-frontend
    restart: unless-stopped
    ports:
      - "3301:3301"
    environment:
      NGINX_PORT: 3301
      QUERY_SERVICE_URL: http://signoz-query:8080
    depends_on:
      - signoz-query
EOF
info "docker-compose.yml created."

section "Step 7: Starting SigNoz"
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
sleep 10
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^signoz-frontend$' || true)
if [ -z "$RUNNING" ]; then
    warn "SigNoz frontend may not have started. Check: docker logs signoz-frontend"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for SigNoz frontend to be ready on port 3301..."
HEALTH_OK=0
for i in $(seq 1 18); do
    if curl -sf --max-time 5 http://127.0.0.1:3301 &>/dev/null; then
        info "Port 3301 is responding — SigNoz is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/18 — waiting 10s..."
    sleep 10
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 3301 2>/dev/null; then
        warn "Port 3301 is open but SigNoz may still be initializing."
        warn "Check logs: docker logs signoz-frontend"
    else
        warn "Port 3301 is NOT responding."
        docker logs --tail 20 signoz-query 2>&1 || true
    fi
fi

section "Step 10: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    ufw allow 3301/tcp
    ufw allow 8080/tcp
    ufw allow 4317/tcp
    ufw allow 4318/tcp
    info "UFW: ports 3301, 8080, 4317, 4318/tcp opened."
else
    warn "UFW not found — skipping firewall rules."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  SigNoz Dashboard:                            ║"
echo "  ║      👉  http://$SERVER_IP:3301"
echo "  ║                                                      ║"
echo "  ║  📡  Send traces from your app (OpenTelemetry):   ║"
echo "  ║      OTLP gRPC : $SERVER_IP:4317"
echo "  ║      OTLP HTTP : $SERVER_IP:4318"
echo "  ║                                                      ║"
echo "  ║  🔑  Create your admin account on first visit.     ║"
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
