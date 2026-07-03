#!/bin/bash
# ============================================================
#   Taiga Auto-Installer
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
echo "  ║   Taiga Auto-Installer"
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
SERVICE_DIR="/root/docker/taiga"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^(taiga-gateway|taiga-front|taiga-back|taiga-events|taiga-protected|taiga-events-rabbitmq|taiga-db)$' || true)
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
mkdir -p "$SERVICE_DIR" "$SERVICE_DIR/db" "$SERVICE_DIR/static" "$SERVICE_DIR/media"
cd "$SERVICE_DIR" || error "Cannot navigate to $SERVICE_DIR"
info "Directory ready: $SERVICE_DIR"

section "Step 6: Generating Configuration & docker-compose.yml"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 24)
SECRET_KEY=$(openssl rand -hex 32)
RABBIT_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 24)
ERLANG_COOKIE=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
info "Secrets generated."

cat > "$SERVICE_DIR/docker-compose.yml" <<EOF
services:
  taiga-db:
    image: postgres:12
    container_name: taiga-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: taiga
      POSTGRES_USER: taiga
      POSTGRES_PASSWORD: $DB_PASS
    volumes:
      - ./db:/var/lib/postgresql/data
    networks:
      - taiga-net

  taiga-events-rabbitmq:
    image: rabbitmq:3-management-alpine
    container_name: taiga-events-rabbitmq
    restart: unless-stopped
    hostname: taiga-events-rabbitmq
    environment:
      RABBITMQ_ERLANG_COOKIE: $ERLANG_COOKIE
      RABBITMQ_DEFAULT_USER: taiga
      RABBITMQ_DEFAULT_PASS: $RABBIT_PASS
      RABBITMQ_DEFAULT_VHOST: taiga
    networks:
      - taiga-net

  taiga-back:
    image: taigaio/taiga-back:latest
    container_name: taiga-back
    restart: unless-stopped
    depends_on:
      - taiga-db
      - taiga-events-rabbitmq
    environment:
      POSTGRES_DB: taiga
      POSTGRES_USER: taiga
      POSTGRES_PASSWORD: $DB_PASS
      POSTGRES_HOST: taiga-db
      TAIGA_SECRET_KEY: $SECRET_KEY
      TAIGA_SITES_SCHEME: http
      TAIGA_SITES_DOMAIN: $SERVER_IP:9013
      EMAIL_BACKEND: django.core.mail.backends.console.EmailBackend
      RABBITMQ_USER: taiga
      RABBITMQ_PASS: $RABBIT_PASS
      ENABLE_TELEMETRY: "False"
      CELERY_ENABLED: "False"
      EVENTS_PUSH_BACKEND_URL: amqp://taiga:$RABBIT_PASS@taiga-events-rabbitmq:5672/taiga
    volumes:
      - ./static:/taiga-back/static
      - ./media:/taiga-back/media
    networks:
      - taiga-net

  taiga-front:
    image: taigaio/taiga-front:latest
    container_name: taiga-front
    restart: unless-stopped
    environment:
      TAIGA_URL: http://$SERVER_IP:9013
      TAIGA_WEBSOCKETS_URL: ws://$SERVER_IP:9013
    networks:
      - taiga-net

  taiga-events:
    image: taigaio/taiga-events:latest
    container_name: taiga-events
    restart: unless-stopped
    depends_on:
      - taiga-events-rabbitmq
    environment:
      RABBITMQ_USER: taiga
      RABBITMQ_PASS: $RABBIT_PASS
      TAIGA_SECRET_KEY: $SECRET_KEY
    networks:
      - taiga-net

  taiga-protected:
    image: taigaio/taiga-protected:latest
    container_name: taiga-protected
    restart: unless-stopped
    environment:
      MAX_AGE: 360
      SECRET_KEY: $SECRET_KEY
    networks:
      - taiga-net

  taiga-gateway:
    image: nginx:alpine
    container_name: taiga-gateway
    restart: unless-stopped
    depends_on:
      - taiga-front
      - taiga-back
      - taiga-events
    ports:
      - "9013:80"
    volumes:
      - ./taiga.conf:/etc/nginx/conf.d/default.conf
      - ./static:/taiga/static
      - ./media:/taiga/media
    networks:
      - taiga-net

networks:
  taiga-net:
    driver: bridge
EOF
info "docker-compose.yml created."

cat > "$SERVICE_DIR/taiga.conf" <<'CONFIG'
server {
    listen 80 default_server;
    client_max_body_size 100M;
    charset utf-8;

    location / {
        proxy_pass http://taiga-front/;
        proxy_pass_header Server;
        proxy_set_header Host $http_host;
        proxy_redirect off;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Scheme $scheme;
    }

    location /api/ {
        proxy_pass http://taiga-back:8000/api/;
        proxy_pass_header Server;
        proxy_set_header Host $http_host;
        proxy_redirect off;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Scheme $scheme;
    }

    location /admin/ {
        proxy_pass http://taiga-back:8000/admin/;
        proxy_pass_header Server;
        proxy_set_header Host $http_host;
        proxy_redirect off;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Scheme $scheme;
    }

    location /static/ {
        alias /taiga/static/;
    }

    location /_protected/ {
        internal;
        alias /taiga/media/;
        add_header Content-disposition "attachment";
    }

    location /media/exports/ {
        alias /taiga/media/exports/;
        add_header Content-disposition "attachment";
    }

    location /media/ {
        proxy_set_header Host $host;
        proxy_pass http://taiga-protected:8003/;
        proxy_redirect off;
    }

    location /events {
        proxy_pass http://taiga-events:8888/events;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_connect_timeout 7d;
        proxy_send_timeout 7d;
        proxy_read_timeout 7d;
    }
}
CONFIG
info "taiga.conf created."

section "Step 7: Starting Taiga"
warn "Taiga is a 7-container stack — first start takes several minutes."
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    docker compose up -d && break
    warn "Docker pull failed on attempt $attempt/$MAX_RETRIES."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed to start after $MAX_RETRIES attempts."
done

section "Step 8: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    ufw allow 9013/tcp
    info "UFW: required ports opened."
else
    warn "UFW not found — skipping firewall rules."
fi

section "Step 9: Verifying Containers"
sleep 10
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^taiga-gateway$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs taiga-gateway"
else
    info "Container running: $RUNNING"
fi

section "Step 10: Health Check"
info "Waiting for Taiga to be ready on port 9013..."
HEALTH_OK=0
for i in $(seq 1 48); do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://127.0.0.1:9013 2>/dev/null || echo "000")
    if echo "$STATUS" | grep -qE '^(200|301|302|303|401)$'; then
        info "Port 9013 is responding (HTTP $STATUS) — Taiga is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/48 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 9013 2>/dev/null; then
        warn "Port 9013 is open but HTTP did not respond. Service may still be starting."
    else
        warn "Port 9013 is NOT responding yet."
        docker logs --tail 20 taiga-gateway 2>&1 || true
    fi
    warn "Check logs: docker logs taiga-gateway"
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  📊  Taiga (agile PM):  http://$SERVER_IP:9013"
echo "  ║  ➕  Create the admin user:"
echo "  ║      docker exec -it taiga-back python manage.py createsuperuser"
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
