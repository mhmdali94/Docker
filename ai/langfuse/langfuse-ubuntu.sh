#!/bin/bash
#
# ============================================================
#   Langfuse Auto-Installer
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
echo "  ║         Langfuse Auto-Installer                  ║"
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
for cname in langfuse langfuse-db; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    if [ -n "$EXISTING" ]; then
        warn "Removing existing container: $cname"
        docker rm -f "$cname" 2>/dev/null || true
    fi
done
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
LF_DIR="/root/docker/langfuse"
if [ -d "$LF_DIR" ]; then
    warn "Removing old directory $LF_DIR..."
    rm -rf "$LF_DIR"
fi
mkdir -p "$LF_DIR"
cd "$LF_DIR" || error "Cannot navigate to $LF_DIR"
info "Directory ready: $LF_DIR"

section "Step 6: Generating Credentials & docker-compose.yml"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
NEXTAUTH_SECRET=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)
ENCRYPTION_KEY=$(tr -dc 'a-f0-9' < /dev/urandom | head -c 64)
SALT=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)
info "Register your account on first visit at http://$SERVER_IP:3006"

cat > "$LF_DIR/docker-compose.yml" <<EOF
services:
  langfuse-db:
    image: postgres:15
    container_name: langfuse-db
    restart: unless-stopped
    environment:
      POSTGRES_USER: langfuse
      POSTGRES_PASSWORD: $DB_PASS
      POSTGRES_DB: langfuse
    volumes:
      - ./postgres:/var/lib/postgresql/data

  langfuse:
    image: langfuse/langfuse:latest
    container_name: langfuse
    restart: unless-stopped
    ports:
      - "3006:3000"
    environment:
      DATABASE_URL: postgresql://langfuse:$DB_PASS@langfuse-db:5432/langfuse
      NEXTAUTH_URL: http://$SERVER_IP:3006
      NEXTAUTH_SECRET: $NEXTAUTH_SECRET
      ENCRYPTION_KEY: $ENCRYPTION_KEY
      SALT: $SALT
      TELEMETRY_ENABLED: "false"
      LANGFUSE_ENABLE_EXPERIMENTAL_FEATURES: "false"
    depends_on:
      - langfuse-db
EOF
info "docker-compose.yml created."

section "Step 7: Starting Langfuse"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 8: Verifying Container"
sleep 10
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^langfuse$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs langfuse"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for Langfuse to be ready on port 3006..."
HEALTH_OK=0
for i in $(seq 1 12); do
    if curl -sf --max-time 5 http://127.0.0.1:3006 &>/dev/null; then
        info "Port 3006 is responding — Langfuse is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 10s..."
    sleep 10
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    warn "Langfuse may still be initializing. Check: docker logs langfuse"
fi

section "Step 10: Opening Firewall Port 3006"
if command -v ufw &> /dev/null; then
    ufw allow 3006/tcp
    info "UFW: port 3006/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Langfuse in your browser:              ║"
echo "  ║      👉  http://$SERVER_IP:3006"
echo "  ║                                                      ║"
echo "  ║  🔑  Register your account on first visit.         ║"
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
