#!/bin/bash
# ============================================================
#   Rust Game Server Auto-Installer
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
echo "  ║     Rust Game Server Auto-Installer             ║"
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
warn "Rust requires a Steam Game Server Login Token (GSLT)."
warn "Get one free at: https://steamcommunity.com/dev/managegameservers (App ID: 252490)"
echo ""
read -rp "  Steam GSLT token (required): " RUST_TOKEN
[ -z "$RUST_TOKEN" ] && error "GSLT token is required for Rust servers."
read -rp "  Server name [My Rust Server]: " SERVER_NAME
SERVER_NAME="${SERVER_NAME:-My Rust Server}"
read -rp "  Server description [A Rust Server]: " SERVER_DESC
SERVER_DESC="${SERVER_DESC:-A Rust Server}"
RCON_PASS=$(openssl rand -hex 12)
read -rp "  RCON password [$RCON_PASS]: " INPUT_RCON
RCON_PASS="${INPUT_RCON:-$RCON_PASS}"
read -rp "  Max players [50]: " MAX_PLAYERS
MAX_PLAYERS="${MAX_PLAYERS:-50}"
read -rp "  Map size (1000-6000) [3000]: " MAP_SIZE
MAP_SIZE="${MAP_SIZE:-3000}"
MAP_SEED=$((RANDOM * RANDOM % 2147483647))
info "Server: $SERVER_NAME | Players: $MAX_PLAYERS | Map size: $MAP_SIZE"

section "Step 5: Cleaning Up Existing Containers"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^rust$" || true)
[ -n "$EXISTING" ] && warn "Removing rust..." && docker rm -f rust 2>/dev/null || true

section "Step 6: Preparing Directory"
APP_DIR="/root/docker/rust"
mkdir -p "$APP_DIR/data" "$APP_DIR/oxide"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 7: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  rust:
    image: linuxserver/rust:latest
    container_name: rust
    restart: unless-stopped
    ports:
      - "28015:28015/udp"
      - "28015:28015/tcp"
      - "28016:28016/tcp"
    environment:
      PUID: 1000
      PGID: 1000
      TZ: UTC
      RUST_SERVER_STARTUP_ARGUMENTS: >-
        -batchmode
        +server.ip 0.0.0.0
        +server.port 28015
        +server.queryport 28017
        +server.maxplayers ${MAX_PLAYERS}
        +server.hostname "${SERVER_NAME}"
        +server.description "${SERVER_DESC}"
        +server.url ""
        +server.identity myserver
        +server.worldsize ${MAP_SIZE}
        +server.seed ${MAP_SEED}
        +rcon.ip 0.0.0.0
        +rcon.port 28016
        +rcon.password ${RCON_PASS}
        +rcon.web 1
        +server.gamemode vanilla
        +app.listenip 0.0.0.0
        +app.port 28082
    volumes:
      - ./data:/config/serverfiles
      - ./oxide:/config/serverfiles/oxide
EOF
info "docker-compose.yml created."

section "Step 8: Starting Rust Server"
warn "Downloading Rust dedicated server (~7 GB) — first start takes 15-30 minutes..."
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start."
else
    docker-compose up -d || error "Failed to start."
fi

section "Step 9: Waiting for Server (~20 min first start)"
info "Waiting for Rust server to start..."
for i in $(seq 1 36); do
    if docker logs rust 2>&1 | grep -q "Server startup complete"; then
        info "Rust server is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/36 — waiting 10s..."
    sleep 10
    echo " retrying"
done

section "Step 10: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 28015/udp
    ufw allow 28015/tcp
    ufw allow 28016/tcp
    ufw allow 28017/udp
    ufw allow 28082/tcp
    info "UFW: Rust ports opened."
else
    warn "UFW not found — skipping."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🔨  Rust Server:                                  ║"
printf  "  ║      Address: %-39s║\n" "$SERVER_IP:28015"
echo "  ║                                                      ║"
printf  "  ║      Name:       %-36s║\n" "$SERVER_NAME"
printf  "  ║      Map Size:   %-36s║\n" "$MAP_SIZE (seed: $MAP_SEED)"
printf  "  ║      RCON Pass:  %-36s║\n" "$RCON_PASS"
echo "  ║                                                      ║"
echo "  ║  📋  RCON WebUI: http://$SERVER_IP:28016"
echo "  ║  📋  Monitor: docker logs -f rust                  ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
