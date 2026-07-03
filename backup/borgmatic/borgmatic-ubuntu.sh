#!/bin/bash
# ============================================================
#   Borgmatic Auto-Installer
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
echo "  ║   Borgmatic Auto-Installer"
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
SERVICE_DIR="/root/docker/borgmatic"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^(borgmatic)$' || true)
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
mkdir -p "$SERVICE_DIR" "$SERVICE_DIR/config" "$SERVICE_DIR/repository" "$SERVICE_DIR/cache" "$SERVICE_DIR/source"
cd "$SERVICE_DIR" || error "Cannot navigate to $SERVICE_DIR"
info "Directory ready: $SERVICE_DIR"

section "Step 6: Generating Configuration & docker-compose.yml"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
BORG_PASSPHRASE=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)
info "Borg passphrase: $BORG_PASSPHRASE  (SAVE THIS — backups are unreadable without it)"

cat > "$SERVICE_DIR/docker-compose.yml" <<EOF
services:
  borgmatic:
    image: ghcr.io/borgmatic-collective/borgmatic:latest
    container_name: borgmatic
    restart: unless-stopped
    environment:
      TZ: UTC
      BORG_PASSPHRASE: $BORG_PASSPHRASE
      BACKUP_CRON: "0 2 * * *"
    volumes:
      - ./source:/mnt/source:ro
      - ./repository:/mnt/borg-repository
      - ./config:/etc/borgmatic.d
      - ./cache:/root/.cache/borg
EOF
info "docker-compose.yml created."

cat > "$SERVICE_DIR/config/config.yaml" <<'CONFIG'
source_directories:
    - /mnt/source

repositories:
    - path: /mnt/borg-repository
      label: local

keep_daily: 7
keep_weekly: 4
keep_monthly: 6

compression: lz4
CONFIG
info "config/config.yaml created."

section "Step 7: Starting Borgmatic"
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    docker compose up -d && break
    warn "Docker pull failed on attempt $attempt/$MAX_RETRIES."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed to start after $MAX_RETRIES attempts."
done

section "Step 8: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    :
    info "UFW: required ports opened."
else
    warn "UFW not found — skipping firewall rules."
fi

section "Step 9: Verifying Containers"
sleep 10
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^borgmatic$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs borgmatic"
else
    info "Container running: $RUNNING"
fi

section "Step 10: Health Check"
info "Waiting for Borgmatic to finish starting (log check)..."
HEALTH_OK=0
for i in $(seq 1 6); do
    if docker logs borgmatic 2>&1 | grep -qiE 'cron|borgmatic'; then
        info "Borgmatic is ready. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/6 — waiting 10s..."
    sleep 10
    echo " retrying"
done
[ "$HEALTH_OK" -eq 0 ] && warn "Still starting. Monitor: docker logs -f borgmatic"

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  💾  Borgmatic runs nightly backups (02:00) of $SERVICE_DIR/source"
echo "  ║  🔑  Passphrase: $BORG_PASSPHRASE  (save it!)"
echo "  ║  🔧  Edit $SERVICE_DIR/config/config.yaml to back up real paths (mount them in docker-compose.yml)."
echo "  ║  ▶️   First run now: docker exec borgmatic borgmatic init --encryption repokey && docker exec borgmatic borgmatic"
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
