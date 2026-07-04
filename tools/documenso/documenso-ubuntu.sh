#!/bin/bash
# ============================================================
#   Documenso Auto-Installer
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
echo "  ║   Documenso Auto-Installer"
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
SERVICE_DIR="/root/docker/documenso"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^(documenso|documenso-db)$' || true)
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
mkdir -p "$SERVICE_DIR" "$SERVICE_DIR/db" "$SERVICE_DIR/cert"
cd "$SERVICE_DIR" || error "Cannot navigate to $SERVICE_DIR"
info "Directory ready: $SERVICE_DIR"

section "Step 6: Generating Configuration & docker-compose.yml"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 24)
NEXTAUTH_SECRET=$(openssl rand -hex 32)
ENC_KEY=$(openssl rand -hex 32)
ENC_KEY2=$(openssl rand -hex 32)
P12_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 16)
info "Generating self-signed document signing certificate..."
openssl req -x509 -nodes -newkey rsa:2048 -keyout "$SERVICE_DIR/cert/key.pem" -out "$SERVICE_DIR/cert/cert.pem" -days 3650 -subj "/CN=Documenso Demo" 2>/dev/null
openssl pkcs12 -export -legacy -out "$SERVICE_DIR/cert/cert.p12" -inkey "$SERVICE_DIR/cert/key.pem" -in "$SERVICE_DIR/cert/cert.pem" -passout "pass:$P12_PASS" 2>/dev/null \
  || openssl pkcs12 -export -out "$SERVICE_DIR/cert/cert.p12" -inkey "$SERVICE_DIR/cert/key.pem" -in "$SERVICE_DIR/cert/cert.pem" -passout "pass:$P12_PASS"
chmod 644 "$SERVICE_DIR/cert/cert.p12"
info "Signing certificate ready."

cat > "$SERVICE_DIR/docker-compose.yml" <<EOF
services:
  documenso-db:
    image: postgres:16-alpine
    container_name: documenso-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: documenso
      POSTGRES_USER: documenso
      POSTGRES_PASSWORD: $DB_PASS
    volumes:
      - ./db:/var/lib/postgresql/data
    networks:
      - documenso-net

  documenso:
    image: documenso/documenso:latest
    container_name: documenso
    restart: unless-stopped
    depends_on:
      - documenso-db
    ports:
      - "3062:3000"
    environment:
      NEXTAUTH_URL: http://$SERVER_IP:3062
      NEXTAUTH_SECRET: $NEXTAUTH_SECRET
      NEXT_PRIVATE_ENCRYPTION_KEY: $ENC_KEY
      NEXT_PRIVATE_ENCRYPTION_SECONDARY_KEY: $ENC_KEY2
      NEXT_PUBLIC_WEBAPP_URL: http://$SERVER_IP:3062
      NEXT_PRIVATE_DATABASE_URL: postgresql://documenso:$DB_PASS@documenso-db:5432/documenso
      NEXT_PRIVATE_DIRECT_DATABASE_URL: postgresql://documenso:$DB_PASS@documenso-db:5432/documenso
      NEXT_PRIVATE_SIGNING_LOCAL_FILE_PATH: /opt/documenso/cert.p12
      NEXT_PRIVATE_SIGNING_PASSPHRASE: $P12_PASS
    volumes:
      - ./cert/cert.p12:/opt/documenso/cert.p12:ro
    networks:
      - documenso-net

networks:
  documenso-net:
    driver: bridge
EOF
info "docker-compose.yml created."

section "Step 7: Starting Documenso"
warn "First start runs migrations — allow a few minutes."
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    docker compose up -d && break
    warn "Docker pull failed on attempt $attempt/$MAX_RETRIES."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed to start after $MAX_RETRIES attempts."
done

section "Step 8: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    ufw allow 3062/tcp
    info "UFW: required ports opened."
else
    warn "UFW not found — skipping firewall rules."
fi

section "Step 9: Verifying Containers"
sleep 10
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^documenso$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs documenso"
else
    info "Container running: $RUNNING"
fi

section "Step 10: Health Check"
info "Waiting for Documenso to be ready on port 3062..."
HEALTH_OK=0
for i in $(seq 1 36); do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://127.0.0.1:3062 2>/dev/null || echo "000")
    if echo "$STATUS" | grep -qE '^(200|301|302|303|401)$'; then
        info "Port 3062 is responding (HTTP $STATUS) — Documenso is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/36 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 3062 2>/dev/null; then
        warn "Port 3062 is open but HTTP did not respond. Service may still be starting."
    else
        warn "Port 3062 is NOT responding yet."
        docker logs --tail 20 documenso 2>&1 || true
    fi
    warn "Check logs: docker logs documenso"
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  ✍️   Documenso (open-source DocuSign):  http://$SERVER_IP:3062"
echo "  ║  🔧  Sign up on first visit. A self-signed signing certificate was generated for demo use."
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
