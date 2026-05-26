#!/bin/bash
# ============================================================
#   Team Fortress 2 Server Auto-Installer
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
echo "  ║     Team Fortress 2 Server Auto-Installer       ║"
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
read -rp "  Server name [My TF2 Server]: " SERVER_NAME
SERVER_NAME="${SERVER_NAME:-My TF2 Server}"
RCON_PASS=$(openssl rand -hex 8)
read -rp "  RCON password [$RCON_PASS]: " INPUT_RCON
RCON_PASS="${INPUT_RCON:-$RCON_PASS}"
read -rp "  Max players [24]: " MAX_PLAYERS
MAX_PLAYERS="${MAX_PLAYERS:-24}"
read -rp "  Start map [cp_badlands]: " START_MAP
START_MAP="${START_MAP:-cp_badlands}"
info "Server: $SERVER_NAME | Map: $START_MAP | Players: $MAX_PLAYERS"

section "Step 5: Cleaning Up Existing Containers"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^tf2$" || true)
[ -n "$EXISTING" ] && warn "Removing tf2..." && docker rm -f tf2 2>/dev/null || true

section "Step 6: Preparing Directory"
APP_DIR="/root/docker/tf2"
mkdir -p "$APP_DIR/data"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 7: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  tf2:
    image: cm2network/tf2:latest
    container_name: tf2
    restart: unless-stopped
    ports:
      - "27015:27015/tcp"
      - "27015:27015/udp"
      - "27020:27020/udp"
    environment:
      SRCDS_TOKEN: ""
      SRCDS_RCONPW: "${RCON_PASS}"
      SRCDS_PW: ""
      SRCDS_STARTMAP: "${START_MAP}"
      SRCDS_MAXPLAYERS: "${MAX_PLAYERS}"
      SRCDS_HOSTNAME: "${SERVER_NAME}"
    volumes:
      - ./data:/home/steam/tf-dedicated
EOF
info "docker-compose.yml created."

section "Step 8: Starting TF2 Server"
warn "Downloading TF2 server (~15 GB) — first start takes 15-30 minutes..."
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start."
else
    docker-compose up -d || error "Failed to start."
fi

section "Step 9: Waiting for Server (~20 min first start)"
info "Waiting for TF2 server to start..."
for i in $(seq 1 36); do
    if docker logs tf2 2>&1 | grep -q "VAC secure mode"; then
        info "TF2 server is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/36 — waiting 10s..."
    sleep 10
    echo " retrying"
done

section "Step 10: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 27015/tcp
    ufw allow 27015/udp
    ufw allow 27020/udp
    info "UFW: TF2 ports opened."
else
    warn "UFW not found — skipping."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🎩  Team Fortress 2 Server:                       ║"
printf  "  ║      Address: %-39s║\n" "$SERVER_IP:27015"
echo "  ║                                                      ║"
printf  "  ║      Name:       %-36s║\n" "$SERVER_NAME"
printf  "  ║      Map:        %-36s║\n" "$START_MAP"
printf  "  ║      RCON Pass:  %-36s║\n" "$RCON_PASS"
echo "  ║                                                      ║"
echo "  ║  📋  Connect in TF2: connect $SERVER_IP:27015"
echo "  ║  📋  Monitor: docker logs -f tf2                   ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║                                                      ║"
echo "  ║  ☕  Support This Script                             ║"
echo "  ║                                                      ║"
echo "  ║  If this script saved you time, consider sending a  ║"
echo "  ║  small tip in USDT. It keeps the content free and   ║"
echo "  ║  helps publish more guides.                         ║"
echo "  ║                                                      ║"
echo "  ║  USDT · TRC-20:                                     ║"
echo "  ║  TCSZTkXvhibdrFre5sdTsFLRQ6d6yQkd2i               ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  TRC-20 network only. Do not send on ERC-20.   ║"
echo "  ║      Funds sent on other networks cannot be         ║"
echo "  ║      recovered.                                     ║"
echo "  ║                                                      ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
