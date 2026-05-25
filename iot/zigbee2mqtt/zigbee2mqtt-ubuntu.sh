#!/bin/bash
# ============================================================
#   Zigbee2MQTT Auto-Installer
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
echo "  ║     Zigbee2MQTT Auto-Installer                  ║"
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

section "Step 4: Configuration"
echo ""
echo "  Zigbee2MQTT needs your Zigbee USB adapter path."
echo "  Common paths:"
echo "    /dev/ttyUSB0   — Most USB Zigbee adapters (CC2531, etc.)"
echo "    /dev/ttyACM0   — ConBee II, sonoff Zigbee dongle"
echo ""
# List available serial devices to help user
SERIAL_DEVICES=$(ls /dev/ttyUSB* /dev/ttyACM* 2>/dev/null | tr '\n' ' ' || echo "none found")
echo "  Detected serial devices: $SERIAL_DEVICES"
echo ""
read -rp "  Enter your Zigbee adapter path [/dev/ttyUSB0]: " ZIGBEE_DEVICE
ZIGBEE_DEVICE="${ZIGBEE_DEVICE:-/dev/ttyUSB0}"

echo ""
echo "  MQTT broker connection:"
SERVER_IP_DEFAULT=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
read -rp "  MQTT broker host [$SERVER_IP_DEFAULT]: " MQTT_HOST
MQTT_HOST="${MQTT_HOST:-$SERVER_IP_DEFAULT}"
read -rp "  MQTT broker port [1883]: " MQTT_PORT
MQTT_PORT="${MQTT_PORT:-1883}"
read -rp "  MQTT username (leave blank if anonymous): " MQTT_USER
read -rp "  MQTT password (leave blank if anonymous): " MQTT_PASS
info "Zigbee adapter: $ZIGBEE_DEVICE"
info "MQTT broker: $MQTT_HOST:$MQTT_PORT"

section "Step 5: Cleaning Up Existing Containers"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^zigbee2mqtt$" || true)
[ -n "$EXISTING" ] && warn "Removing existing container..." && docker rm -f zigbee2mqtt 2>/dev/null || true

section "Step 6: Preparing Directory"
APP_DIR="/root/docker/zigbee2mqtt"
mkdir -p "$APP_DIR/data"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 7: Writing configuration.yaml"
cat > "$APP_DIR/data/configuration.yaml" <<EOF
homeassistant: true
permit_join: true

mqtt:
  base_topic: zigbee2mqtt
  server: mqtt://${MQTT_HOST}:${MQTT_PORT}
$([ -n "$MQTT_USER" ] && echo "  user: ${MQTT_USER}")
$([ -n "$MQTT_PASS" ] && echo "  password: ${MQTT_PASS}")

serial:
  port: ${ZIGBEE_DEVICE}

frontend:
  port: 8080

advanced:
  log_level: info
EOF
info "configuration.yaml created."

section "Step 8: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  zigbee2mqtt:
    image: koenkk/zigbee2mqtt:latest
    container_name: zigbee2mqtt
    restart: unless-stopped
    ports:
      - "8080:8080"
    volumes:
      - ./data:/app/data
      - /run/udev:/run/udev:ro
    devices:
      - ${ZIGBEE_DEVICE}:${ZIGBEE_DEVICE}
    environment:
      TZ: UTC
EOF
info "docker-compose.yml created."

section "Step 9: Starting Zigbee2MQTT"
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start. Run: cd $APP_DIR && docker compose up -d"
else
    docker-compose up -d || error "Failed to start. Run: cd $APP_DIR && docker-compose up -d"
fi

section "Step 10: Health Check"
info "Waiting for Zigbee2MQTT to be ready..."
for i in $(seq 1 12); do
    if curl -sf --max-time 3 http://127.0.0.1:8080 &>/dev/null; then
        info "Zigbee2MQTT is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done

section "Step 11: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 8080/tcp
    info "UFW: port 8080 opened."
else
    warn "UFW not found — skipping."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  📡  Zigbee2MQTT Frontend:                         ║"
echo "  ║      👉  http://$SERVER_IP:8080"
echo "  ║                                                      ║"
echo "  ║  🔌  Zigbee adapter: $ZIGBEE_DEVICE"
echo "  ║  📡  MQTT broker:    $MQTT_HOST:$MQTT_PORT"
echo "  ║                                                      ║"
echo "  ║  💡  Tip: Devices pair while permit_join: true      ║"
echo "  ║      Disable after pairing for security:            ║"
echo "  ║      Set permit_join: false in configuration.yaml   ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
