#!/bin/bash
# ============================================================
#   Factorio Server Auto-Installer
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
echo "  ║     Factorio Server Auto-Installer              ║"
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
read -rp "  Server name [My Factorio Server]: " SERVER_NAME
SERVER_NAME="${SERVER_NAME:-My Factorio Server}"
read -rp "  Server description [A Factorio Server]: " SERVER_DESC
SERVER_DESC="${SERVER_DESC:-A Factorio Server}"
ADMIN_PASS=$(openssl rand -hex 8)
read -rp "  Admin password [$ADMIN_PASS]: " INPUT_PASS
ADMIN_PASS="${INPUT_PASS:-$ADMIN_PASS}"
read -rp "  Max players (0 = unlimited) [0]: " MAX_PLAYERS
MAX_PLAYERS="${MAX_PLAYERS:-0}"
info "Server: $SERVER_NAME | Max players: ${MAX_PLAYERS:-unlimited}"

section "Step 5: Cleaning Up Existing Containers"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^factorio$" || true)
[ -n "$EXISTING" ] && warn "Removing factorio..." && docker rm -f factorio 2>/dev/null || true

section "Step 6: Preparing Directory"
APP_DIR="/root/docker/factorio"
mkdir -p "$APP_DIR/config" "$APP_DIR/saves" "$APP_DIR/mods"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 7: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  factorio:
    image: factoriotools/factorio:stable
    container_name: factorio
    restart: unless-stopped
    ports:
      - "34197:34197/udp"
      - "27015:27015/tcp"
    environment:
      GENERATE_NEW_SAVE: "true"
      SAVE_NAME: myworld
      PORT: 34197
      RCON_PORT: 27015
      RCON_PASSWORD: "${ADMIN_PASS}"
    volumes:
      - ./config:/factorio/config
      - ./saves:/factorio/saves
      - ./mods:/factorio/mods
EOF
info "docker-compose.yml created."

section "Step 8: Writing server-settings.json"
cat > "$APP_DIR/config/server-settings.json" <<EOF
{
  "name": "${SERVER_NAME}",
  "description": "${SERVER_DESC}",
  "max_players": ${MAX_PLAYERS},
  "visibility": {
    "public": true,
    "lan": true
  },
  "username": "",
  "password": "",
  "token": "",
  "game_password": "",
  "require_user_verification": false,
  "max_upload_in_kilobytes_per_second": 0,
  "minimum_latency_in_ticks": 0,
  "allow_commands": "admins-only",
  "autosave_interval": 10,
  "autosave_slots": 5,
  "afk_autokick_interval": 0,
  "auto_pause": true,
  "only_admins_can_pause_the_game": true
}
EOF
info "server-settings.json created."

section "Step 9: Starting Factorio Server"
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start."
else
    docker-compose up -d || error "Failed to start."
fi

section "Step 10: Waiting for Server (~30s)"
info "Waiting for Factorio server to start..."
for i in $(seq 1 12); do
    if docker logs factorio 2>&1 | grep -q "Hosting game"; then
        info "Factorio server is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done

section "Step 11: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 34197/udp
    ufw allow 27015/tcp
    info "UFW: ports 34197 UDP and 27015 TCP opened."
else
    warn "UFW not found — skipping."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  ⚙️   Factorio Server:                             ║"
printf  "  ║      Address: %-39s║\n" "$SERVER_IP:34197"
echo "  ║                                                      ║"
printf  "  ║      Name:      %-37s║\n" "$SERVER_NAME"
printf  "  ║      RCON Pass: %-37s║\n" "$ADMIN_PASS"
echo "  ║                                                      ║"
echo "  ║  📋  Saves: ./saves/   Mods: ./mods/              ║"
echo "  ║  📋  Monitor: docker logs -f factorio              ║"
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
