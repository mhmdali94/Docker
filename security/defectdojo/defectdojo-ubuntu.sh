#!/bin/bash
#
# ============================================================
#   DefectDojo Auto-Installer
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
echo "  ║         DefectDojo Auto-Installer                ║"
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
for cname in defectdojo defectdojo-db defectdojo-redis; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    if [ -n "$EXISTING" ]; then
        warn "Removing existing container: $cname"
        docker rm -f "$cname" 2>/dev/null || true
    fi
done
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
DD_DIR="/root/docker/defectdojo"
if [ -d "$DD_DIR" ]; then
    warn "Removing old directory $DD_DIR..."
    rm -rf "$DD_DIR"
fi
mkdir -p "$DD_DIR/media"
cd "$DD_DIR" || error "Cannot navigate to $DD_DIR"
info "Directory ready: $DD_DIR"

section "Step 6: Generating Credentials & docker-compose.yml"
DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
SECRET=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 50)
AES_KEY=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)
ADMIN_PASS=$(tr -dc 'A-Za-z0-9!@#' < /dev/urandom | head -c 20)
info "Admin User     : admin"
info "Admin Password : $ADMIN_PASS"

cat > "$DD_DIR/docker-compose.yml" <<EOF
services:
  defectdojo-db:
    image: postgres:15
    container_name: defectdojo-db
    restart: unless-stopped
    environment:
      POSTGRES_USER: defectdojo
      POSTGRES_PASSWORD: $DB_PASS
      POSTGRES_DB: defectdojo
    volumes:
      - ./postgres:/var/lib/postgresql/data

  defectdojo-redis:
    image: redis:7
    container_name: defectdojo-redis
    restart: unless-stopped
    volumes:
      - ./redis:/data

  defectdojo:
    image: defectdojo/defectdojo-django:latest
    container_name: defectdojo
    restart: unless-stopped
    ports:
      - "8092:8080"
    environment:
      DD_DATABASE_URL: postgresql://defectdojo:$DB_PASS@defectdojo-db:5432/defectdojo
      DD_CELERY_BROKER_URL: redis://defectdojo-redis:6379/0
      DD_SECRET_KEY: $SECRET
      DD_CREDENTIAL_AES_256_KEY: $AES_KEY
      DD_ADMIN_USER: admin
      DD_ADMIN_MAIL: admin@defectdojo.local
      DD_ADMIN_FIRST_NAME: Admin
      DD_ADMIN_LAST_NAME: User
      DD_ADMIN_PASSWORD: $ADMIN_PASS
      DD_ALLOWED_HOSTS: "*"
      DD_DEBUG: "False"
    volumes:
      - ./media:/app/media
    depends_on:
      - defectdojo-db
      - defectdojo-redis
EOF
info "docker-compose.yml created."

section "Step 7: Starting DefectDojo"
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
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^defectdojo$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs defectdojo"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for DefectDojo to be ready on port 8092 (may take ~3 minutes)..."
HEALTH_OK=0
for i in $(seq 1 24); do
    if curl -sf --max-time 5 http://127.0.0.1:8092 &>/dev/null; then
        info "Port 8092 is responding — DefectDojo is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/24 — waiting 10s..."
    sleep 10
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 8092 2>/dev/null; then
        warn "Port 8092 is open but DefectDojo may still be initializing."
        warn "Check logs: docker logs defectdojo"
    else
        warn "Port 8092 is NOT responding."
        docker logs --tail 20 defectdojo 2>&1 || true
    fi
fi

section "Step 10: Opening Firewall Port 8092"
if command -v ufw &> /dev/null; then
    ufw allow 8092/tcp
    info "UFW: port 8092/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open DefectDojo in your browser:             ║"
echo "  ║      👉  http://$SERVER_IP:8092"
echo "  ║                                                      ║"
echo "  ║  🔑  Login Credentials (save these!):              ║"
echo "  ║      Username : admin"
echo "  ║      Password : $ADMIN_PASS"
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
