#!/bin/bash
# ============================================================
#   Minecraft Java Edition Server Auto-Installer
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
echo "  ║     Minecraft Java Server Auto-Installer        ║"
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
read -rp "  Server name [My Minecraft Server]: " SERVER_NAME
SERVER_NAME="${SERVER_NAME:-My Minecraft Server}"
read -rp "  Max players [20]: " MAX_PLAYERS
MAX_PLAYERS="${MAX_PLAYERS:-20}"
read -rp "  Memory (e.g. 2G, 4G) [2G]: " MEM
MEM="${MEM:-2G}"
read -rp "  Game mode (survival/creative/adventure) [survival]: " GAMEMODE
GAMEMODE="${GAMEMODE:-survival}"
read -rp "  Difficulty (peaceful/easy/normal/hard) [normal]: " DIFFICULTY
DIFFICULTY="${DIFFICULTY:-normal}"
read -rp "  Allow online-mode/auth (true/false) [true]: " ONLINE_MODE
ONLINE_MODE="${ONLINE_MODE:-true}"
info "Server: $SERVER_NAME | Players: $MAX_PLAYERS | RAM: $MEM"

section "Step 5: Cleaning Up Existing Containers"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^minecraft-java$" || true)
[ -n "$EXISTING" ] && warn "Removing minecraft-java..." && docker rm -f minecraft-java 2>/dev/null || true

section "Step 6: Preparing Directory"
APP_DIR="/root/docker/minecraft-java"
mkdir -p "$APP_DIR/data"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 7: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  minecraft-java:
    image: itzg/minecraft-server:latest
    container_name: minecraft-java
    restart: unless-stopped
    ports:
      - "25565:25565"
    environment:
      EULA: "TRUE"
      TYPE: VANILLA
      VERSION: LATEST
      SERVER_NAME: "${SERVER_NAME}"
      MAX_PLAYERS: "${MAX_PLAYERS}"
      MEMORY: "${MEM}"
      MODE: "${GAMEMODE}"
      DIFFICULTY: "${DIFFICULTY}"
      ONLINE_MODE: "${ONLINE_MODE}"
      ENABLE_RCON: "true"
      RCON_PASSWORD: "$(openssl rand -hex 12)"
      RCON_PORT: 25575
      MOTD: "${SERVER_NAME}"
      ALLOW_FLIGHT: "false"
      MAX_WORLD_SIZE: 29999984
      VIEW_DISTANCE: 10
    volumes:
      - ./data:/data
    stdin_open: true
    tty: true
EOF
info "docker-compose.yml created."

section "Step 8: Starting Minecraft Java Server"
warn "Downloading Minecraft server — this may take a minute..."
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start."
else
    docker-compose up -d || error "Failed to start."
fi

section "Step 9: Waiting for Server (~60s)"
info "Waiting for Minecraft server to start..."
for i in $(seq 1 12); do
    if docker logs minecraft-java 2>&1 | grep -q "Done"; then
        info "Minecraft Java server is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/12 — waiting 10s..."
    sleep 10
    echo " retrying"
done

section "Step 10: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 25565/tcp
    ufw allow 25575/tcp
    info "UFW: ports 25565 and 25575 opened."
else
    warn "UFW not found — skipping."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  ⛏️   Minecraft Java Server:                       ║"
printf  "  ║      Address: %-39s║\n" "$SERVER_IP:25565"
echo "  ║                                                      ║"
printf  "  ║      Name: %-43s║\n" "$SERVER_NAME"
printf  "  ║      RAM:  %-43s║\n" "$MEM"
echo "  ║                                                      ║"
echo "  ║  📋  Useful commands:                              ║"
echo "  ║      docker attach minecraft-java  (console)       ║"
echo "  ║      docker exec minecraft-java rcon-cli           ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║                                                      ║"
echo "  ║  🚀  Need production setup?                         ║"
echo "  ║      👨‍💻  Mohammed Ali Elshikh                      ║"
echo "  ║      🌐  prismatechwork.com                         ║"
echo "  ║                                                      ║"
echo "  ║  ☕  Support this script — USDT (TRC-20 only):     ║"
echo "  ║      TCSZTkXvhibdrFre5sdTsFLRQ6d6yQkd2i           ║"
echo "  ║                                                      ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
