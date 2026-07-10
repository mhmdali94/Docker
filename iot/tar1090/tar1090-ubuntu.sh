#!/bin/bash
# ============================================================
#   tar1090 (ADS-B Flight Tracking) Auto-Installer
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
echo "  ║   tar1090 (ADS-B Flight Tracking) Auto-Installer"
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
SERVICE_DIR="/root/docker/tar1090"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^(tar1090)$' || true)
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
mkdir -p "$SERVICE_DIR" "$SERVICE_DIR/globe_history" "$SERVICE_DIR/graphs1090"
cd "$SERVICE_DIR" || error "Cannot navigate to $SERVICE_DIR"
info "Directory ready: $SERVICE_DIR"

section "Step 6: Generating Configuration & docker-compose.yml"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
warn "REQUIRES an RTL-SDR USB dongle with antenna plugged into this machine."
read -rp "  Your latitude (e.g. 30.0444): " FEEDER_LAT
read -rp "  Your longitude (e.g. 31.2357): " FEEDER_LON
[ -z "$FEEDER_LAT" ] && error "Latitude is required."
[ -z "$FEEDER_LON" ] && error "Longitude is required."

cat > "$SERVICE_DIR/docker-compose.yml" <<EOF
services:
  tar1090:
    image: ghcr.io/sdr-enthusiasts/docker-tar1090:latest
    container_name: tar1090
    restart: unless-stopped
    devices:
      - /dev/bus/usb:/dev/bus/usb
    ports:
      - "8316:80"
    environment:
      TZ: UTC
      READSB_DEVICE_TYPE: rtlsdr
      READSB_GAIN: auto
      LAT: $FEEDER_LAT
      LONG: $FEEDER_LON
    volumes:
      - ./globe_history:/var/globe_history
      - ./graphs1090:/var/lib/collectd
EOF
info "docker-compose.yml created."

section "Step 7: Starting tar1090 (ADS-B Flight Tracking)"
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    docker compose up -d && break
    warn "Docker pull failed on attempt $attempt/$MAX_RETRIES."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed to start after $MAX_RETRIES attempts."
done

section "Step 8: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    ufw allow 8316/tcp
    info "UFW: required ports opened."
else
    warn "UFW not found — skipping firewall rules."
fi

section "Step 9: Verifying Containers"
sleep 10
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^tar1090$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs tar1090"
else
    info "Container running: $RUNNING"
fi

section "Step 10: Health Check"
info "Waiting for tar1090 (ADS-B Flight Tracking) to be ready on port 8316..."
HEALTH_OK=0
for i in $(seq 1 24); do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://127.0.0.1:8316 2>/dev/null || echo "000")
    if echo "$STATUS" | grep -qE '^(200|301|302|303|401)$'; then
        info "Port 8316 is responding (HTTP $STATUS) — tar1090 (ADS-B Flight Tracking) is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/24 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 8316 2>/dev/null; then
        warn "Port 8316 is open but HTTP did not respond. Service may still be starting."
    else
        warn "Port 8316 is NOT responding yet."
        docker logs --tail 20 tar1090 2>&1 || true
    fi
    warn "Check logs: docker logs tar1090"
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  ✈️   tar1090 (live aircraft map):  http://$SERVER_IP:8316"
echo "  ║  📈  Stats: http://$SERVER_IP:8316/graphs1090/"
echo "  ║  ⚠️   Needs an RTL-SDR dongle + antenna to receive aircraft."
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
