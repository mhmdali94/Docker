#!/bin/bash
#
# ============================================================
#   Wazuh Auto-Installer
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
echo "  ║           Wazuh Auto-Installer                   ║"
echo "  ║           Made by: Mohammed Ali Elshikh         ║"
echo "  ║           prismatechwork.com                    ║"
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
for cname in wazuh-manager wazuh-indexer wazuh-dashboard; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    if [ -n "$EXISTING" ]; then
        warn "Removing existing container: $cname"
        docker rm -f "$cname" 2>/dev/null || true
    fi
done
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory & SSL Certificates"
WAZUH_DIR="/root/docker/wazuh"
if [ -d "$WAZUH_DIR" ]; then
    warn "Removing old directory $WAZUH_DIR..."
    rm -rf "$WAZUH_DIR"
fi
mkdir -p "$WAZUH_DIR/certs"
cd "$WAZUH_DIR" || error "Cannot navigate to $WAZUH_DIR"

info "Generating self-signed SSL certificate..."
apt-get install -y openssl &>/dev/null || true
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$WAZUH_DIR/certs/wazuh.key" \
    -out "$WAZUH_DIR/certs/wazuh.crt" \
    -subj "/C=US/ST=State/L=City/O=Wazuh/CN=wazuh" 2>/dev/null
info "SSL certificate generated."

section "Step 6: Generating Credentials & docker-compose.yml"
WAZUH_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
info "Admin User     : admin"
info "Admin Password : $WAZUH_PASS"

sysctl -w vm.max_map_count=262144
info "vm.max_map_count set (required for OpenSearch/Wazuh Indexer)."

cat > "$WAZUH_DIR/docker-compose.yml" <<EOF
services:
  wazuh-indexer:
    image: wazuh/wazuh-indexer:4.7.5
    container_name: wazuh-indexer
    restart: unless-stopped
    ports:
      - "9200:9200"
    environment:
      OPENSEARCH_JAVA_OPTS: -Xms512m -Xmx512m
      bootstrap.memory_lock: "true"
      discovery.type: single-node
      plugins.security.ssl.http.enabled: "false"
      WAZUH_INDEXER_PASSWORD: $WAZUH_PASS
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - ./indexer-data:/var/lib/wazuh-indexer

  wazuh-manager:
    image: wazuh/wazuh-manager:4.7.5
    container_name: wazuh-manager
    restart: unless-stopped
    ports:
      - "1514:1514/udp"
      - "1515:1515"
      - "55000:55000"
    environment:
      WAZUH_INDEXER_URL: https://wazuh-indexer:9200
      WAZUH_INDEXER_PASSWORD: $WAZUH_PASS
    volumes:
      - ./manager-data:/var/ossec/data
      - ./certs:/etc/ssl/wazuh

  wazuh-dashboard:
    image: wazuh/wazuh-dashboard:4.7.5
    container_name: wazuh-dashboard
    restart: unless-stopped
    ports:
      - "8443:443"
    environment:
      INDEXER_URL: https://wazuh-indexer:9200
      INDEXER_USERNAME: admin
      INDEXER_PASSWORD: $WAZUH_PASS
      WAZUH_API_URL: https://wazuh-manager
      DASHBOARD_USERNAME: admin
      DASHBOARD_PASSWORD: $WAZUH_PASS
    volumes:
      - ./certs:/usr/share/wazuh-dashboard/certs
    depends_on:
      - wazuh-indexer
      - wazuh-manager
EOF
info "docker-compose.yml created."

section "Step 7: Starting Wazuh"
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

section "Step 8: Verifying Containers"
sleep 15
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^wazuh-dashboard$' || true)
if [ -z "$RUNNING" ]; then
    warn "Wazuh dashboard may not have started. Check: docker logs wazuh-dashboard"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for Wazuh Dashboard on port 8443 (may take 3-5 minutes)..."
HEALTH_OK=0
for i in $(seq 1 24); do
    if curl -sk --max-time 5 https://127.0.0.1:8443 &>/dev/null; then
        info "Port 8443 is responding — Wazuh Dashboard is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/24 — waiting 15s..."
    sleep 15
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    warn "Wazuh may still be initializing. Check: docker logs wazuh-dashboard"
fi

section "Step 10: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    ufw allow 8443/tcp
    ufw allow 1514/udp
    ufw allow 1515/tcp
    ufw allow 55000/tcp
    ufw allow 9200/tcp
    info "UFW: ports 8443, 1514/udp, 1515, 55000, 9200 opened."
else
    warn "UFW not found — skipping firewall rules."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Wazuh Dashboard (accept SSL warning):        ║"
echo "  ║      👉  https://$SERVER_IP:8443"
echo "  ║                                                      ║"
echo "  ║  🔑  Login Credentials (save these!):              ║"
echo "  ║      Username : admin"
echo "  ║      Password : $WAZUH_PASS"
echo "  ║                                                      ║"
echo "  ║  📡  Agent enrollment port : 1515/tcp              ║"
echo "  ║  📥  Log collection port   : 1514/udp              ║"
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
