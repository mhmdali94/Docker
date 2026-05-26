#!/bin/bash
#
# ============================================================
#   Tubearchivist Auto-Installer
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
echo "  ║         Tubearchivist Auto-Installer             ║"
echo "  ║         Made by: Mohammed Ali Elshikh           ║"
echo "  ║         prismatechwork.com                      ║"
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
for cname in tubearchivist tubearchivist-es tubearchivist-redis; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    if [ -n "$EXISTING" ]; then
        warn "Removing existing container: $cname"
        docker rm -f "$cname" 2>/dev/null || true
    fi
done
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory & System Tuning"
TA_DIR="/root/docker/tubearchivist"
if [ -d "$TA_DIR" ]; then
    warn "Removing old directory $TA_DIR..."
    rm -rf "$TA_DIR"
fi
mkdir -p "$TA_DIR"/{youtube,cache,es,redis}
cd "$TA_DIR" || error "Cannot navigate to $TA_DIR"
info "Directory ready: $TA_DIR"
sysctl -w vm.max_map_count=262144
info "vm.max_map_count set (required for Elasticsearch)."

section "Step 6: Generating Credentials & docker-compose.yml"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
TA_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
ELASTIC_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
info "Admin User     : admin"
info "Admin Password : $TA_PASS"

cat > "$TA_DIR/docker-compose.yml" <<EOF
services:
  tubearchivist-es:
    image: bbilly1/tubearchivist-es:latest
    container_name: tubearchivist-es
    restart: unless-stopped
    environment:
      ES_JAVA_OPTS: "-Xms512m -Xmx512m"
      xpack.security.enabled: "true"
      ELASTIC_PASSWORD: $ELASTIC_PASS
      discovery.type: single-node
    volumes:
      - ./es:/usr/share/elasticsearch/data
    ulimits:
      memlock:
        soft: -1
        hard: -1

  tubearchivist-redis:
    image: redis:7
    container_name: tubearchivist-redis
    restart: unless-stopped
    volumes:
      - ./redis:/data

  tubearchivist:
    image: bbilly1/tubearchivist:latest
    container_name: tubearchivist
    restart: unless-stopped
    ports:
      - "8098:8000"
    environment:
      ES_URL: http://tubearchivist-es:9200
      REDIS_HOST: tubearchivist-redis
      HOST_UID: 1000
      HOST_GID: 1000
      TA_HOST: $SERVER_IP
      TA_USERNAME: admin
      TA_PASSWORD: $TA_PASS
      ELASTIC_PASSWORD: $ELASTIC_PASS
      TZ: UTC
    volumes:
      - ./youtube:/youtube
      - ./cache:/cache
    depends_on:
      - tubearchivist-es
      - tubearchivist-redis
EOF
info "docker-compose.yml created."

section "Step 7: Starting Tubearchivist"
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
sleep 20
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^tubearchivist$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs tubearchivist"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for Tubearchivist to be ready on port 8098 (may take ~3 minutes)..."
HEALTH_OK=0
for i in $(seq 1 24); do
    if curl -sf --max-time 5 http://127.0.0.1:8098 &>/dev/null; then
        info "Port 8098 is responding — Tubearchivist is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/24 — waiting 10s..."
    sleep 10
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    warn "Tubearchivist may still be initializing. Check: docker logs tubearchivist"
fi

section "Step 10: Opening Firewall Port 8098"
if command -v ufw &> /dev/null; then
    ufw allow 8098/tcp
    info "UFW: port 8098/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Tubearchivist in your browser:          ║"
echo "  ║      👉  http://$SERVER_IP:8098"
echo "  ║                                                      ║"
echo "  ║  🔑  Login Credentials (save these!):              ║"
echo "  ║      Username : admin"
echo "  ║      Password : $TA_PASS"
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
