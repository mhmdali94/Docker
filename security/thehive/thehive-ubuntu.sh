#!/bin/bash
# ============================================================
#   TheHive Auto-Installer
#   Made by: Mohammed Ali Elshikh | prismatechwork.com
#   ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️
# ============================================================
set -e

info()    { echo -e "\e[32m[INFO]\e[0m $*"; }
warn()    { echo -e "\e[33m[WARN]\e[0m $*"; }
error()   { echo -e "\e[31m[ERROR]\e[0m $*"; exit 1; }
section() { echo -e "\n\e[36m========== $* ==========\e[0m"; }

clear
echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║   TheHive Auto-Installer"
echo "  ║   Made by: Mohammed Ali Elshikh"
echo "  ║   prismatechwork.com"
echo "  ║"
echo "  ║   ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️"
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

section "Step 4: Cleaning Up Existing Containers & Data"
SERVICE_DIR="/root/docker/thehive"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^(thehive|thehive-cassandra|thehive-elasticsearch)$' || true)
if [ -n "$EXISTING" ]; then
    warn "Stopping and removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
    info "Containers removed."
else
    info "No existing containers found."
fi
if [ -d "$SERVICE_DIR" ]; then
    warn "Removing existing configuration at $SERVICE_DIR..."
    rm -rf "$SERVICE_DIR"
    info "Configuration removed."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
mkdir -p "$SERVICE_DIR" "$SERVICE_DIR/cassandra" "$SERVICE_DIR/elasticsearch" "$SERVICE_DIR/data"
cd "$SERVICE_DIR" || error "Cannot navigate to $SERVICE_DIR"
info "Directory ready: $SERVICE_DIR"

section "Step 6: Generating Configuration & docker-compose.yml"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
SECRET=$(openssl rand -hex 32)
chown -R 1000:1000 "$SERVICE_DIR/elasticsearch" "$SERVICE_DIR/data"
warn "TheHive needs at least 8 GB RAM (Cassandra + Elasticsearch + TheHive)."
info "Secret generated."

cat > "$SERVICE_DIR/docker-compose.yml" <<EOF
services:
  thehive-cassandra:
    image: cassandra:4.1
    container_name: thehive-cassandra
    restart: unless-stopped
    environment:
      CASSANDRA_CLUSTER_NAME: TheHive
      MAX_HEAP_SIZE: 1024M
      HEAP_NEWSIZE: 1024M
    volumes:
      - ./cassandra:/var/lib/cassandra
    networks:
      - thehive-net

  thehive-elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.17.28
    container_name: thehive-elasticsearch
    restart: unless-stopped
    environment:
      discovery.type: single-node
      xpack.security.enabled: "false"
      ES_JAVA_OPTS: -Xms1g -Xmx1g
    volumes:
      - ./elasticsearch:/usr/share/elasticsearch/data
    networks:
      - thehive-net

  thehive:
    image: strangebee/thehive:5.5
    container_name: thehive
    restart: unless-stopped
    depends_on:
      - thehive-cassandra
      - thehive-elasticsearch
    ports:
      - "9014:9000"
    command: --secret $SECRET --cql-hostnames thehive-cassandra --index-backend elasticsearch --es-hostnames thehive-elasticsearch
    volumes:
      - ./data:/opt/thp/thehive/files
    networks:
      - thehive-net

networks:
  thehive-net:
    driver: bridge
EOF
info "docker-compose.yml created."

section "Step 7: Starting TheHive"
warn "Cassandra + Elasticsearch take several minutes to come up before TheHive starts."
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    docker compose up -d && break
    warn "Docker pull failed on attempt $attempt/$MAX_RETRIES."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed to start after $MAX_RETRIES attempts."
done

section "Step 8: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    ufw allow 9014/tcp
    info "UFW: required ports opened."
else
    warn "UFW not found — skipping firewall rules."
fi

section "Step 9: Verifying Containers"
sleep 10
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^thehive$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs thehive"
else
    info "Container running: $RUNNING"
fi

section "Step 10: Health Check"
info "Waiting for TheHive to be ready on port 9014..."
HEALTH_OK=0
for i in $(seq 1 60); do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://127.0.0.1:9014 2>/dev/null || echo "000")
    if echo "$STATUS" | grep -qE '^(200|301|302|303|401)$'; then
        info "Port 9014 is responding (HTTP $STATUS) — TheHive is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/60 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 9014 2>/dev/null; then
        warn "Port 9014 is open but HTTP did not respond. Service may still be starting."
    else
        warn "Port 9014 is NOT responding yet."
        docker logs --tail 20 thehive 2>&1 || true
    fi
    warn "Check logs: docker logs thehive"
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🐝  TheHive (incident response):  http://$SERVER_IP:9014"
echo "  ║  🔑  Default login: admin@thehive.local / secret  (change it!)"
echo "  ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️"
echo "  ║       Made by: Mohammed Ali Elshikh"
echo "  ║       prismatechwork.com"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║  🚀  Need production setup?                         ║"
echo "  ║      👨‍💻  Mohammed Ali Elshikh | prismatechwork.com"
echo "  ║  ☕  USDT (TRC-20): TCSZTkXvhibdrFre5sdTsFLRQ6d6yQkd2i"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
