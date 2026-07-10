#!/bin/bash
# ============================================================
#   Startup Stack Auto-Installer (Plausible + Listmonk + Uptime Kuma)
#   Analytics + newsletters + uptime for a small business
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
echo "  ║   STARTUP STACK Auto-Installer"
echo "  ║   Plausible (analytics) + Listmonk (newsletters)"
echo "  ║   + Uptime Kuma (monitoring) — one command"
echo "  ║"
echo "  ║   Made by: Mohammed Ali Elshikh | prismatechwork.com"
echo "  ║   ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""
echo "  Press ENTER to continue... Ctrl+C to cancel."
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
else
    info "Docker: $(docker --version)"
fi

section "Step 3: Checking Docker Compose V2"
if ! docker compose version &> /dev/null; then
    warn "Docker Compose V2 not found. Installing..."
    apt update -y && apt install -y docker-compose-v2 || apt install -y docker-compose
fi
info "Docker Compose: $(docker compose version)"

section "Step 4: Cleaning Up Existing Containers & Data"
SERVICE_DIR="/root/docker/startup-stack"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^ss-(plausible|plausible-db|plausible-events-db|listmonk|listmonk-db|listmonk-init|uptime-kuma)$' || true)
if [ -n "$EXISTING" ]; then
    warn "Stopping and removing existing stack containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
fi
if [ -d "$SERVICE_DIR" ]; then
    warn "Removing existing configuration at $SERVICE_DIR..."
    rm -rf "$SERVICE_DIR"
fi
docker network prune -f &>/dev/null || true
info "Cleanup complete."

section "Step 5: Preparing Directories"
mkdir -p "$SERVICE_DIR"/{plausible-db,clickhouse,listmonk-db,uptime-kuma}
cd "$SERVICE_DIR" || error "Cannot navigate to $SERVICE_DIR"
info "Directory ready: $SERVICE_DIR"

section "Step 6: Generating Credentials & docker-compose.yml"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
PL_DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 24)
PL_SECRET=$(openssl rand -base64 64 | tr -d '\n')
LM_DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 24)
LM_ADMIN_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
info "Listmonk login: admin / $LM_ADMIN_PASS"

cat > "$SERVICE_DIR/docker-compose.yml" <<EOF
services:
  ss-plausible-db:
    image: postgres:16-alpine
    container_name: ss-plausible-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: plausible_db
      POSTGRES_USER: plausible
      POSTGRES_PASSWORD: $PL_DB_PASS
    volumes:
      - ./plausible-db:/var/lib/postgresql/data
    networks: [startup-net]

  ss-plausible-events-db:
    image: clickhouse/clickhouse-server:24.3-alpine
    container_name: ss-plausible-events-db
    restart: unless-stopped
    volumes:
      - ./clickhouse:/var/lib/clickhouse
    ulimits:
      nofile:
        soft: 262144
        hard: 262144
    networks: [startup-net]

  ss-plausible:
    image: ghcr.io/plausible/community-edition:v2
    container_name: ss-plausible
    restart: unless-stopped
    command: sh -c "sleep 10 && /entrypoint.sh db createdb && /entrypoint.sh db migrate && /entrypoint.sh run"
    depends_on:
      - ss-plausible-db
      - ss-plausible-events-db
    ports:
      - "8100:8000"
    environment:
      BASE_URL: http://$SERVER_IP:8100
      SECRET_KEY_BASE: $PL_SECRET
      DATABASE_URL: postgres://plausible:$PL_DB_PASS@ss-plausible-db:5432/plausible_db
      CLICKHOUSE_DATABASE_URL: http://ss-plausible-events-db:8123/plausible_events_db
      DISABLE_REGISTRATION: invite_only
    networks: [startup-net]

  ss-listmonk-db:
    image: postgres:16-alpine
    container_name: ss-listmonk-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: listmonk
      POSTGRES_USER: listmonk
      POSTGRES_PASSWORD: $LM_DB_PASS
    volumes:
      - ./listmonk-db:/var/lib/postgresql/data
    networks: [startup-net]

  ss-listmonk-init:
    image: listmonk/listmonk:latest
    container_name: ss-listmonk-init
    restart: "no"
    depends_on:
      - ss-listmonk-db
    command: sh -c "sleep 8 && ./listmonk --install --idempotent --yes --config ''"
    environment: &lm-env
      LISTMONK_app__address: 0.0.0.0:9000
      LISTMONK_db__host: ss-listmonk-db
      LISTMONK_db__port: 5432
      LISTMONK_db__user: listmonk
      LISTMONK_db__password: $LM_DB_PASS
      LISTMONK_db__database: listmonk
      LISTMONK_db__ssl_mode: disable
      LISTMONK_ADMIN_USER: admin
      LISTMONK_ADMIN_PASSWORD: $LM_ADMIN_PASS
    networks: [startup-net]

  ss-listmonk:
    image: listmonk/listmonk:latest
    container_name: ss-listmonk
    restart: unless-stopped
    depends_on:
      ss-listmonk-init:
        condition: service_completed_successfully
    ports:
      - "9000:9000"
    command: sh -c "./listmonk --config ''"
    environment: *lm-env
    networks: [startup-net]

  ss-uptime-kuma:
    image: louislam/uptime-kuma:1
    container_name: ss-uptime-kuma
    restart: unless-stopped
    ports:
      - "3001:3001"
    volumes:
      - ./uptime-kuma:/app/data
    networks: [startup-net]

networks:
  startup-net:
    driver: bridge
EOF
info "docker-compose.yml created."

section "Step 7: Starting the Startup Stack"
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    docker compose up -d && break
    warn "Docker pull failed on attempt $attempt/$MAX_RETRIES."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed to start after $MAX_RETRIES attempts."
done

section "Step 8: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    for p in 8100/tcp 9000/tcp 3001/tcp; do ufw allow "$p"; done
    info "UFW: stack ports opened."
else
    warn "UFW not found — skipping firewall rules."
fi

section "Step 9: Verifying Containers"
sleep 12
RUNNING=$(docker ps --format '{{.Names}}' | grep -c '^ss-' || true)
info "Stack containers running: $RUNNING/6 (init container exits by design)"

section "Step 10: Health Checks"
for svc in "8100 Plausible" "9000 Listmonk" "3001 Uptime-Kuma"; do
    port=${svc%% *}; name=${svc#* }
    OK=0
    for i in $(seq 1 18); do
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 "http://127.0.0.1:$port" 2>/dev/null || echo "000")
        [ "$STATUS" != "000" ] && { info "$name responding (HTTP $STATUS) ✅"; OK=1; break; }
        sleep 5
    done
    [ "$OK" -eq 0 ] && warn "$name not responding yet on port $port."
done

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║             ✅  STARTUP STACK READY!                 ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  📈  Plausible (analytics):   http://$SERVER_IP:8100"
echo "  ║      Create your account on first visit, add your"
echo "  ║      site, embed the snippet."
echo "  ║  📮  Listmonk (newsletters):  http://$SERVER_IP:9000"
echo "  ║      Login: admin / $LM_ADMIN_PASS"
echo "  ║  ⏱️   Uptime Kuma (monitoring): http://$SERVER_IP:3001"
echo "  ║      Create admin on first visit, add your site as"
echo "  ║      a monitor."
echo "  ║"
echo "  ║  💡  Complete the belt: support/chatwoot (live chat)"
echo "  ║      and tools/calcom (booking) from this repo."
echo "  ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️"
echo "  ║       Made by: Mohammed Ali Elshikh | prismatechwork.com"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║  🚀  Need production setup?                         ║"
echo "  ║      👨‍💻  Mohammed Ali Elshikh | prismatechwork.com"
echo "  ║  ☕  USDT (TRC-20): TCSZTkXvhibdrFre5sdTsFLRQ6d6yQkd2i"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
