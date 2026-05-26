#!/bin/bash
# ============================================================
#   Terraria Server Auto-Installer
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
echo "  ║     Terraria Server Auto-Installer              ║"
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
read -rp "  World name [MyWorld]: " WORLD_NAME
WORLD_NAME="${WORLD_NAME:-MyWorld}"
read -rp "  World size (1=small, 2=medium, 3=large) [2]: " WORLD_SIZE
WORLD_SIZE="${WORLD_SIZE:-2}"
read -rp "  Difficulty (0=normal, 1=expert, 2=master) [0]: " DIFFICULTY
DIFFICULTY="${DIFFICULTY:-0}"
read -rp "  Max players [8]: " MAX_PLAYERS
MAX_PLAYERS="${MAX_PLAYERS:-8}"
read -rp "  Server password (leave empty for none): " SERVER_PASS
info "World: $WORLD_NAME | Size: $WORLD_SIZE | Players: $MAX_PLAYERS"

section "Step 5: Cleaning Up Existing Containers"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^terraria$" || true)
[ -n "$EXISTING" ] && warn "Removing terraria..." && docker rm -f terraria 2>/dev/null || true

section "Step 6: Preparing Directory"
APP_DIR="/root/docker/terraria"
mkdir -p "$APP_DIR/world" "$APP_DIR/config"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 7: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  terraria:
    image: linuxserver/terraria:latest
    container_name: terraria
    restart: unless-stopped
    ports:
      - "7777:7777/tcp"
    environment:
      PUID: 1000
      PGID: 1000
      TZ: UTC
      WORLD: /config/world/${WORLD_NAME}.wld
      AUTOCREATE: "${WORLD_SIZE}"
      WORLDNAME: "${WORLD_NAME}"
      MAXPLAYERS: "${MAX_PLAYERS}"
      PASSWORD: "${SERVER_PASS}"
      DIFFICULTY: "${DIFFICULTY}"
    volumes:
      - ./world:/config/world
      - ./config:/config
    stdin_open: true
    tty: true
EOF
info "docker-compose.yml created."

section "Step 8: Starting Terraria Server"
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start."
else
    docker-compose up -d || error "Failed to start."
fi

section "Step 9: Waiting for Server (~60s)"
info "Waiting for Terraria server to start..."
for i in $(seq 1 18); do
    if docker logs terraria 2>&1 | grep -q "Listening on port"; then
        info "Terraria server is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/18 — waiting 10s..."
    sleep 10
    echo " retrying"
done

section "Step 10: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 7777/tcp
    info "UFW: port 7777 TCP opened."
else
    warn "UFW not found — skipping."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🌳  Terraria Server:                              ║"
printf  "  ║      Address: %-39s║\n" "$SERVER_IP:7777"
echo "  ║                                                      ║"
printf  "  ║      World:      %-36s║\n" "$WORLD_NAME"
printf  "  ║      Max Players:%-36s║\n" "$MAX_PLAYERS"
[ -n "$SERVER_PASS" ] && printf "  ║      Password:   %-36s║\n" "$SERVER_PASS"
echo "  ║                                                      ║"
echo "  ║  📋  World files: ./world/                         ║"
echo "  ║  📋  Monitor: docker logs -f terraria              ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
