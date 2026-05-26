#!/bin/bash
# ============================================================
#   OpenRA Server Auto-Installer
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
echo "  ║     OpenRA Server Auto-Installer                ║"
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
echo "  Available game mods:"
echo "    ra       — Red Alert"
echo "    cnc      — Tiberian Dawn (C&C)"
echo "    d2k      — Dune 2000"
echo ""
read -rp "  Game mod (ra/cnc/d2k) [ra]: " GAME_MOD
GAME_MOD="${GAME_MOD:-ra}"
read -rp "  Server name [My OpenRA Server]: " SERVER_NAME
SERVER_NAME="${SERVER_NAME:-My OpenRA Server}"
read -rp "  Max players [8]: " MAX_PLAYERS
MAX_PLAYERS="${MAX_PLAYERS:-8}"
ADMIN_PASS=$(openssl rand -hex 6)
read -rp "  Admin password [$ADMIN_PASS]: " INPUT_PASS
ADMIN_PASS="${INPUT_PASS:-$ADMIN_PASS}"
info "Game: $GAME_MOD | Server: $SERVER_NAME | Players: $MAX_PLAYERS"

section "Step 5: Cleaning Up Existing Containers"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^openra$" || true)
[ -n "$EXISTING" ] && warn "Removing openra..." && docker rm -f openra 2>/dev/null || true

section "Step 6: Preparing Directory"
APP_DIR="/root/docker/openra"
mkdir -p "$APP_DIR/data"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 7: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  openra:
    image: rmoriz/openra:release-20231010
    container_name: openra
    restart: unless-stopped
    ports:
      - "1234:1234/tcp"
    environment:
      OPENRA_MOD: "${GAME_MOD}"
      SERVER_NAME: "${SERVER_NAME}"
      SERVER_MAXPLAYERS: "${MAX_PLAYERS}"
      SERVER_PASSWORD: ""
      SERVER_REQUIRESJUMPSERVER: "False"
      SERVER_ADVERTISETOMASTER: "True"
      ADMIN_PASSWORD: "${ADMIN_PASS}"
    volumes:
      - ./data:/home/openra/.openra
EOF
info "docker-compose.yml created."

section "Step 8: Starting OpenRA Server"
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start."
else
    docker-compose up -d || error "Failed to start."
fi

section "Step 9: Waiting for Server (~30s)"
info "Waiting for OpenRA server to start..."
for i in $(seq 1 12); do
    if docker logs openra 2>&1 | grep -q "Master server"; then
        info "OpenRA server is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done

section "Step 10: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 1234/tcp
    info "UFW: port 1234 TCP opened."
else
    warn "UFW not found — skipping."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🎖️   OpenRA Server:                               ║"
printf  "  ║      Address: %-39s║\n" "$SERVER_IP:1234"
echo "  ║                                                      ║"
printf  "  ║      Game:       %-36s║\n" "$GAME_MOD"
printf  "  ║      Name:       %-36s║\n" "$SERVER_NAME"
printf  "  ║      Admin Pass: %-36s║\n" "$ADMIN_PASS"
echo "  ║                                                      ║"
echo "  ║  📋  Monitor: docker logs -f openra                ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
