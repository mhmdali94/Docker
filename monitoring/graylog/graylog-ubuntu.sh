#!/bin/bash
#
# ============================================================
#   Graylog Log Management Auto-Installer
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
echo "  ║       Graylog Log Management Auto-Installer      ║"
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

section "Step 4: Setting vm.max_map_count for OpenSearch"
sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
info "vm.max_map_count set to 262144."

section "Step 5: Cleaning Up Existing Containers"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E 'graylog' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing Graylog containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 6: Preparing Directory"
GRAYLOG_DIR="/root/docker/graylog"
if [ -d "$GRAYLOG_DIR" ]; then
    warn "Removing old directory $GRAYLOG_DIR..."
    rm -rf "$GRAYLOG_DIR"
fi
mkdir -p "$GRAYLOG_DIR/graylog-data" "$GRAYLOG_DIR/opensearch-data" "$GRAYLOG_DIR/mongo-data"
chown -R 1100:1100 "$GRAYLOG_DIR/graylog-data"
cd "$GRAYLOG_DIR" || error "Cannot navigate to $GRAYLOG_DIR"
info "Directory ready: $GRAYLOG_DIR"

section "Step 7: Generating Credentials & docker-compose.yml"
GL_PASSWORD_SECRET=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 96)
GL_ADMIN_PASS=$(tr -dc 'A-Za-z0-9!@#$%' < /dev/urandom | head -c 20)
GL_ADMIN_PASS_SHA2=$(echo -n "$GL_ADMIN_PASS" | sha256sum | awk '{print $1}')
SERVER_IP_SETUP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
info "Admin User     : admin"
info "Admin Password : $GL_ADMIN_PASS"

cat > "$GRAYLOG_DIR/docker-compose.yml" <<EOF
services:
  graylog-mongo:
    image: mongo:6.0
    container_name: graylog-mongo
    restart: unless-stopped
    volumes:
      - ./mongo-data:/data/db
    networks:
      - graylog-net

  graylog-opensearch:
    image: opensearchproject/opensearch:2.12.0
    container_name: graylog-opensearch
    restart: unless-stopped
    environment:
      - "OPENSEARCH_JAVA_OPTS=-Xms512m -Xmx512m"
      - bootstrap.memory_lock=true
      - discovery.type=single-node
      - plugins.security.disabled=true
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - ./opensearch-data:/usr/share/opensearch/data
    networks:
      - graylog-net

  graylog:
    image: graylog/graylog:6.0
    container_name: graylog
    restart: unless-stopped
    depends_on:
      - graylog-mongo
      - graylog-opensearch
    ports:
      - "9000:9000"
      - "12201:12201/udp"
      - "5140:5140/udp"
      - "5140:5140/tcp"
    environment:
      GRAYLOG_PASSWORD_SECRET: $GL_PASSWORD_SECRET
      GRAYLOG_ROOT_PASSWORD_SHA2: $GL_ADMIN_PASS_SHA2
      GRAYLOG_HTTP_EXTERNAL_URI: http://$SERVER_IP_SETUP:9000/
      GRAYLOG_ELASTICSEARCH_HOSTS: http://graylog-opensearch:9200
      GRAYLOG_MONGODB_URI: mongodb://graylog-mongo:27017/graylog
    volumes:
      - ./graylog-data:/usr/share/graylog/data
    networks:
      - graylog-net

networks:
  graylog-net:
    driver: bridge
EOF
info "docker-compose.yml created."

section "Step 8: Starting Graylog"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 9: Verifying Containers"
sleep 10
RUNNING=$(docker ps --format '{{.Names}}' | grep -E 'graylog' || true)
if [ -z "$RUNNING" ]; then
    warn "Containers may not have started. Check: docker logs graylog"
else
    info "Containers running: $RUNNING"
fi

section "Step 10: Health Check"
info "Waiting for Graylog to be ready on port 9000 (may take up to 2 minutes)..."
HEALTH_OK=0
for i in $(seq 1 24); do
    if curl -sf --max-time 3 http://127.0.0.1:9000/api/system/lbstatus &>/dev/null; then
        info "Port 9000 is responding — Graylog is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/24 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 9000 2>/dev/null; then
        warn "Port 9000 is open but API did not respond. OpenSearch may still be warming up."
        warn "Check logs: docker logs graylog"
    else
        warn "Port 9000 is NOT responding after 120s."
        warn "Check logs: docker logs graylog"
        docker logs --tail 20 graylog 2>&1 || true
    fi
fi

section "Step 11: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    ufw allow 9000/tcp
    ufw allow 12201/udp
    ufw allow 5140/tcp
    ufw allow 5140/udp
    info "UFW: Graylog ports opened."
else
    warn "UFW not found — skipping firewall rules."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Graylog in your browser:                 ║"
echo "  ║      👉  http://$SERVER_IP:9000"
echo "  ║                                                      ║"
echo "  ║  🔑  Login Credentials (save these!):              ║"
echo "  ║      Username : admin"
echo "  ║      Password : $GL_ADMIN_PASS"
echo "  ║                                                      ║"
echo "  ║  📥  Log ingestion ports:                          ║"
echo "  ║      GELF UDP  : 12201"
echo "  ║      Syslog    : 5140 (TCP/UDP)"
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
