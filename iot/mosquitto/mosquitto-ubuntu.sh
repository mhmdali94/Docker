#!/bin/bash
# ============================================================
#   Mosquitto MQTT Broker Auto-Installer
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
echo "  ║     Mosquitto MQTT Broker Auto-Installer        ║"
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
echo "  Authentication options:"
echo "  [1] Anonymous access (no username/password) — for local/trusted networks"
echo "  [2] Username/password authentication — recommended"
echo ""
read -rp "  Choose [1/2]: " AUTH_CHOICE
if [ "$AUTH_CHOICE" = "2" ]; then
    read -rp "  MQTT username [mqtt]: " MQTT_USER
    MQTT_USER="${MQTT_USER:-mqtt}"
    MQTT_PASS=$(openssl rand -base64 12 | tr -d '=+/')
    AUTH_ENABLED=true
    info "Auth enabled. User: $MQTT_USER"
else
    AUTH_ENABLED=false
    warn "Anonymous access enabled. Not recommended for internet-facing servers."
fi

section "Step 5: Cleaning Up Existing Containers"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^mosquitto$" || true)
[ -n "$EXISTING" ] && warn "Removing existing container..." && docker rm -f mosquitto 2>/dev/null || true

section "Step 6: Preparing Directory"
APP_DIR="/root/docker/mosquitto"
mkdir -p "$APP_DIR/config" "$APP_DIR/data" "$APP_DIR/log"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 7: Writing mosquitto.conf"
if [ "$AUTH_ENABLED" = true ]; then
    cat > "$APP_DIR/config/mosquitto.conf" <<EOF
listener 1883
listener 9001
protocol websockets

persistence true
persistence_location /mosquitto/data/

log_dest file /mosquitto/log/mosquitto.log
log_dest stdout

allow_anonymous false
password_file /mosquitto/config/passwd
EOF
    info "Config written with authentication."
    docker run --rm -v "$APP_DIR/config:/mosquitto/config" eclipse-mosquitto:2 \
        mosquitto_passwd -b /mosquitto/config/passwd "$MQTT_USER" "$MQTT_PASS" 2>/dev/null
    info "Password file created."
else
    cat > "$APP_DIR/config/mosquitto.conf" <<'EOF'
listener 1883
listener 9001
protocol websockets

persistence true
persistence_location /mosquitto/data/

log_dest file /mosquitto/log/mosquitto.log
log_dest stdout

allow_anonymous true
EOF
    info "Config written with anonymous access."
fi

section "Step 8: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<'EOF'
services:
  mosquitto:
    image: eclipse-mosquitto:2
    container_name: mosquitto
    restart: unless-stopped
    ports:
      - "1883:1883"
      - "9001:9001"
    volumes:
      - ./config:/mosquitto/config
      - ./data:/mosquitto/data
      - ./log:/mosquitto/log
EOF
info "docker-compose.yml created."

section "Step 9: Starting Mosquitto"
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start. Run: cd $APP_DIR && docker compose up -d"
else
    docker-compose up -d || error "Failed to start. Run: cd $APP_DIR && docker-compose up -d"
fi

section "Step 10: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 1883/tcp
    ufw allow 9001/tcp
    info "UFW: ports 1883 and 9001 opened."
else
    warn "UFW not found — skipping."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  📡  Mosquitto MQTT Broker:                        ║"
echo "  ║      TCP:       $SERVER_IP:1883"
echo "  ║      WebSocket: $SERVER_IP:9001"
echo "  ║                                                      ║"
if [ "$AUTH_ENABLED" = true ]; then
printf  "  ║  🔑  Username: %-38s║\n" "$MQTT_USER"
printf  "  ║      Password: %-38s║\n" "$MQTT_PASS"
else
echo "  ║  🔓  Anonymous access enabled                       ║"
fi
echo "  ║                                                      ║"
echo "  ║  📋  Test: mosquitto_pub -h $SERVER_IP -t test -m hello"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
