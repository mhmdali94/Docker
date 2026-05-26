#!/bin/bash
# ============================================================
#   ARK: Survival Evolved Server Auto-Installer
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
echo "  ║     ARK: Survival Evolved Server Installer      ║"
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
warn "ARK is a very large download (~60 GB) — ensure you have sufficient disk space."
read -rp "  Server name [My ARK Server]: " SERVER_NAME
SERVER_NAME="${SERVER_NAME:-My ARK Server}"
SERVER_PASS=$(openssl rand -hex 8)
read -rp "  Server password [$SERVER_PASS]: " INPUT_PASS
SERVER_PASS="${INPUT_PASS:-$SERVER_PASS}"
ADMIN_PASS=$(openssl rand -hex 8)
read -rp "  Admin password [$ADMIN_PASS]: " INPUT_ADMIN
ADMIN_PASS="${INPUT_ADMIN:-$ADMIN_PASS}"
read -rp "  Map (TheIsland/TheCenter/Ragnarok/Aberration) [TheIsland]: " MAP
MAP="${MAP:-TheIsland}"
read -rp "  Max players [10]: " MAX_PLAYERS
MAX_PLAYERS="${MAX_PLAYERS:-10}"
info "Server: $SERVER_NAME | Map: $MAP | Players: $MAX_PLAYERS"

section "Step 5: Cleaning Up Existing Containers"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^ark$" || true)
[ -n "$EXISTING" ] && warn "Removing ark..." && docker rm -f ark 2>/dev/null || true

section "Step 6: Preparing Directory"
APP_DIR="/root/docker/ark"
mkdir -p "$APP_DIR/data" "$APP_DIR/cluster"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 7: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  ark:
    image: hermsi1337/docker-ark-survival-evolved:latest
    container_name: ark
    restart: unless-stopped
    ports:
      - "7777:7777/udp"
      - "7778:7778/udp"
      - "27015:27015/udp"
      - "32330:32330/tcp"
    environment:
      ARK_SERVER_NAME: "${SERVER_NAME}"
      ARK_SESSION_NAME: "${SERVER_NAME}"
      ARK_SERVER_PASSWORD: "${SERVER_PASS}"
      ARK_ADMIN_PASSWORD: "${ADMIN_PASS}"
      ARK_MAP: "${MAP}"
      ARK_MAX_PLAYERS: "${MAX_PLAYERS}"
      ARK_DIFFICULTY_OFFSET: "0.2"
      ARK_XP_MULTIPLIER: "1.0"
      ARK_TAMING_SPEED_MULTIPLIER: "1.0"
      ARK_HARVESTING_DAMAGE_MULTIPLIER: "1.0"
      ARK_OVERRIDE_OFFICIAL_DIFFICULTY: "5.0"
      ARK_ENABLE_RCON: "true"
      ARK_RCON_PORT: 32330
      ARK_RCON_PASSWORD: "${ADMIN_PASS}"
    volumes:
      - ./data:/ark
      - ./cluster:/arkcluster
EOF
info "docker-compose.yml created."

section "Step 8: Starting ARK Server"
warn "Downloading ARK (~60 GB) — first start takes 1-2 hours..."
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start."
else
    docker-compose up -d || error "Failed to start."
fi

section "Step 9: Waiting for Server (~60 min first download)"
info "Waiting for ARK server to start (very long first download)..."
for i in $(seq 1 36); do
    if docker logs ark 2>&1 | grep -q "Server listening"; then
        info "ARK server is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/36 — waiting 10s..."
    sleep 10
    echo " retrying"
done
warn "If not ready, ARK is still downloading. Monitor with: docker logs -f ark"

section "Step 10: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 7777/udp
    ufw allow 7778/udp
    ufw allow 27015/udp
    ufw allow 32330/tcp
    info "UFW: ARK ports opened."
else
    warn "UFW not found — skipping."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🦕  ARK: Survival Evolved Server:                ║"
printf  "  ║      Address: %-39s║\n" "$SERVER_IP:7777"
echo "  ║                                                      ║"
printf  "  ║      Name:       %-36s║\n" "$SERVER_NAME"
printf  "  ║      Map:        %-36s║\n" "$MAP"
printf  "  ║      Password:   %-36s║\n" "$SERVER_PASS"
printf  "  ║      Admin Pass: %-36s║\n" "$ADMIN_PASS"
echo "  ║                                                      ║"
echo "  ║  📋  Monitor: docker logs -f ark                   ║"
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
