#!/bin/bash
# ============================================================
#   Elasticsearch Auto-Installer
#   Made by: Mohammed Ali Elshikh | prismatechwork.com
#   ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️
# ============================================================
set -e
G="\e[32m"; Y="\e[33m"; R="\e[31m"; C="\e[36m"; B="\e[1m"; RST="\e[0m"
info()    { echo -e "${G}[INFO]${RST} $*"; }
warn()    { echo -e "${Y}[WARN]${RST} $*"; }
error()   { echo -e "${R}[ERROR]${RST} $*"; exit 1; }
section() { echo -e "\n${C}${B}══════════════════════ $* ══════════════════════${RST}"; }

clear
echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║     Elasticsearch Auto-Installer                ║"
echo "  ║     Made by: Mohammed Ali Elshikh              ║"
echo "  ║     prismatechwork.com                         ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️        ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""
echo "  Press ENTER to continue ... Ctrl+C to cancel."
read -rp "" _

section "Step 0: Checking Privileges"
[ "$EUID" -ne 0 ] && error "Please run as root: sudo bash $0"
info "Running as root. OK."

section "Step 1: Verifying OS"
[ -f /etc/os-release ] || error "Cannot determine OS."
. /etc/os-release
[ "$ID" = "ubuntu" ] || error "Only Ubuntu is supported. Found: $ID"
{ [ "$VERSION_ID" = "22.04" ] || [ "$VERSION_ID" = "24.04" ]; } || error "Only Ubuntu 22.04/24.04 supported. Found: $VERSION_ID"
info "OS check passed: Ubuntu $VERSION_ID"

section "Step 2: Checking Docker"
if ! command -v docker &>/dev/null; then
    warn "Docker not found. Installing..."
    apt update -y && apt install -y docker.io
    systemctl enable --now docker
    info "Docker installed."
else
    info "Docker: $(docker --version)"
fi

section "Step 3: Checking Docker Compose V2"
if ! docker compose version &>/dev/null; then
    warn "Docker Compose V2 not found. Installing..."
    apt update -y && apt install -y docker-compose-v2 || apt install -y docker-compose
    info "Docker Compose installed."
else
    info "Docker Compose: $(docker compose version)"
fi

section "Step 4: Kernel Tuning (required by Elasticsearch)"
CURRENT=$(sysctl -n vm.max_map_count 2>/dev/null || echo 0)
if [ "$CURRENT" -lt 262144 ]; then
    sysctl -w vm.max_map_count=262144
    echo "vm.max_map_count=262144" >> /etc/sysctl.conf
    info "vm.max_map_count set to 262144."
else
    info "vm.max_map_count already sufficient: $CURRENT"
fi

section "Step 5: Cleaning Up Existing Containers"
for cname in elasticsearch; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    [ -n "$EXISTING" ] && warn "Removing $cname..." && docker rm -f "$cname" 2>/dev/null || true
done

section "Step 6: Preparing Directory"
APP_DIR="/root/docker/elasticsearch"
mkdir -p "$APP_DIR"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 7: Generating Credentials & docker-compose.yml"
ES_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
info "Credentials generated."

cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.13.4
    container_name: elasticsearch
    restart: unless-stopped
    ports:
      - "9200:9200"
      - "9300:9300"
    environment:
      discovery.type: single-node
      ELASTIC_PASSWORD: ${ES_PASS}
      xpack.security.enabled: "true"
      xpack.security.http.ssl.enabled: "false"
      ES_JAVA_OPTS: "-Xms512m -Xmx512m"
    volumes:
      - ./data:/usr/share/elasticsearch/data
    ulimits:
      memlock:
        soft: -1
        hard: -1
EOF
info "docker-compose.yml created."

section "Step 8: Starting Elasticsearch"
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    if docker compose version &>/dev/null; then
        docker compose up -d && break
    else
        docker-compose up -d && break
    fi
    warn "Attempt $attempt/$MAX_RETRIES failed."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed after $MAX_RETRIES attempts."
done

section "Step 9: Health Check"
info "Waiting for Elasticsearch on port 9200 (may take up to 3 min)..."
HEALTH_OK=0
for i in $(seq 1 18); do
    if curl -s --max-time 5 -u "elastic:${ES_PASS}" http://127.0.0.1:9200/_cluster/health &>/dev/null; then
        info "Port 9200 is responding. ✅"; HEALTH_OK=1; break
    fi
    echo -n "  Attempt $i/18 — waiting 10s..."; sleep 10; echo " retrying"
done
[ "$HEALTH_OK" -eq 0 ] && warn "Not responding. Check: docker logs elasticsearch"

section "Step 10: Opening Firewall"
if command -v ufw &>/dev/null; then
    ufw allow 9200/tcp; info "UFW: port 9200 opened."
else
    warn "UFW not found — skipping."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🔍  Elasticsearch:                                ║"
echo "  ║      REST API : http://$SERVER_IP:9200"
echo "  ║      Username : elastic"
echo "  ║      Password : $ES_PASS"
echo "  ║                                                      ║"
echo "  ║  ⚠️  Save your password — not shown again!         ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║  🚀  Need production setup?                         ║"
echo "  ║      👨‍💻  Mohammed Ali Elshikh                      ║"
echo "  ║      🌐  prismatechwork.com                         ║"
echo "  ║  ☕  USDT (TRC-20): TCSZTkXvhibdrFre5sdTsFLRQ6d6yQkd2i ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
