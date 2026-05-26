#!/bin/bash
# ============================================================
#   Satisfactory Server Auto-Installer
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
echo "  ║     Satisfactory Server Auto-Installer          ║"
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
read -rp "  Max players [4]: " MAX_PLAYERS
MAX_PLAYERS="${MAX_PLAYERS:-4}"
ADMIN_PASS=$(openssl rand -hex 8)
read -rp "  Server admin password [$ADMIN_PASS]: " INPUT_PASS
ADMIN_PASS="${INPUT_PASS:-$ADMIN_PASS}"
info "Max players: $MAX_PLAYERS"

section "Step 5: Cleaning Up Existing Containers"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^satisfactory$" || true)
[ -n "$EXISTING" ] && warn "Removing satisfactory..." && docker rm -f satisfactory 2>/dev/null || true

section "Step 6: Preparing Directory"
APP_DIR="/root/docker/satisfactory"
mkdir -p "$APP_DIR/data"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 7: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  satisfactory:
    image: wolveix/satisfactory-server:latest
    container_name: satisfactory
    restart: unless-stopped
    ports:
      - "7777:7777/udp"
      - "7777:7777/tcp"
      - "15777:15777/udp"
      - "15000:15000/udp"
    environment:
      MAXPLAYERS: "${MAX_PLAYERS}"
      SKIPUPDATE: "false"
      TIMEOUT: 30
      AUTOPAUSE: "false"
      AUTOSAVENUM: 5
      AUTOSAVEONDISCONNECT: "true"
    volumes:
      - ./data:/config
EOF
info "docker-compose.yml created."

section "Step 8: Starting Satisfactory Server"
warn "Downloading Satisfactory server (~5 GB) — first start takes 10-20 minutes..."
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start."
else
    docker-compose up -d || error "Failed to start."
fi

section "Step 9: Waiting for Server (~15 min first start)"
info "Waiting for Satisfactory server to start..."
for i in $(seq 1 36); do
    if docker logs satisfactory 2>&1 | grep -q "Server is ready"; then
        info "Satisfactory server is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/36 — waiting 10s..."
    sleep 10
    echo " retrying"
done

section "Step 10: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 7777/udp
    ufw allow 7777/tcp
    ufw allow 15777/udp
    ufw allow 15000/udp
    info "UFW: Satisfactory ports opened."
else
    warn "UFW not found — skipping."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🏭  Satisfactory Server:                          ║"
printf  "  ║      Address: %-39s║\n" "$SERVER_IP:7777"
echo "  ║                                                      ║"
printf  "  ║      Max Players: %-35s║\n" "$MAX_PLAYERS"
echo "  ║                                                      ║"
echo "  ║  📋  Saves: ./data/saves/                          ║"
echo "  ║  📋  Monitor: docker logs -f satisfactory          ║"
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
