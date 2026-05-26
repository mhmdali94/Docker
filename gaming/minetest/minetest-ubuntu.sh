#!/bin/bash
# ============================================================
#   Minetest Server Auto-Installer
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
echo "  ║     Minetest Server Auto-Installer              ║"
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
read -rp "  Server name [My Minetest Server]: " SERVER_NAME
SERVER_NAME="${SERVER_NAME:-My Minetest Server}"
read -rp "  Server description [A Minetest Server]: " SERVER_DESC
SERVER_DESC="${SERVER_DESC:-A Minetest Server}"
read -rp "  Admin username [admin]: " ADMIN_USER
ADMIN_USER="${ADMIN_USER:-admin}"
ADMIN_PASS=$(openssl rand -hex 8)
read -rp "  Admin password [$ADMIN_PASS]: " INPUT_PASS
ADMIN_PASS="${INPUT_PASS:-$ADMIN_PASS}"
read -rp "  Max players [20]: " MAX_PLAYERS
MAX_PLAYERS="${MAX_PLAYERS:-20}"
info "Server: $SERVER_NAME | Admin: $ADMIN_USER | Players: $MAX_PLAYERS"

section "Step 5: Cleaning Up Existing Containers"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^minetest$" || true)
[ -n "$EXISTING" ] && warn "Removing minetest..." && docker rm -f minetest 2>/dev/null || true

section "Step 6: Preparing Directory"
APP_DIR="/root/docker/minetest"
mkdir -p "$APP_DIR/data"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 7: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  minetest:
    image: linuxserver/minetest:latest
    container_name: minetest
    restart: unless-stopped
    ports:
      - "30000:30000/udp"
    environment:
      PUID: 1000
      PGID: 1000
      TZ: UTC
      CLI_ARGS: >-
        --gameid minetest
        --worldname world
        --name ${SERVER_NAME}
        --password ${ADMIN_PASS}
    volumes:
      - ./data:/config/.minetest
EOF
info "docker-compose.yml created."

section "Step 8: Starting Minetest Server"
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start."
else
    docker-compose up -d || error "Failed to start."
fi

info "Waiting 20s for config files to be created..."
sleep 20

section "Step 9: Configuring Server"
CONF_FILE="$APP_DIR/data/minetest.conf"
if [ -f "$CONF_FILE" ]; then
    {
        echo "server_name = ${SERVER_NAME}"
        echo "server_description = ${SERVER_DESC}"
        echo "max_users = ${MAX_PLAYERS}"
        echo "name = ${ADMIN_USER}"
        echo "server_announce = true"
        echo "enable_pvp = true"
        echo "enable_damage = true"
    } >> "$CONF_FILE"
    docker restart minetest 2>/dev/null || true
    info "minetest.conf updated."
else
    warn "Config not yet created — configure manually in $CONF_FILE"
fi

section "Step 10: Waiting for Server (~60s)"
info "Waiting for Minetest server to start..."
for i in $(seq 1 12); do
    if docker logs minetest 2>&1 | grep -q "listen"; then
        info "Minetest server is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/12 — waiting 10s..."
    sleep 10
    echo " retrying"
done

section "Step 11: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 30000/udp
    info "UFW: port 30000 UDP opened."
else
    warn "UFW not found — skipping."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  ⛏️   Minetest Server:                             ║"
printf  "  ║      Address: %-39s║\n" "$SERVER_IP:30000"
echo "  ║                                                      ║"
printf  "  ║      Name:       %-36s║\n" "$SERVER_NAME"
printf  "  ║      Admin:      %-36s║\n" "$ADMIN_USER"
printf  "  ║      Password:   %-36s║\n" "$ADMIN_PASS"
printf  "  ║      Max Players:%-36s║\n" "$MAX_PLAYERS"
echo "  ║                                                      ║"
echo "  ║  📋  Config: ./data/minetest.conf                  ║"
echo "  ║  📋  Monitor: docker logs -f minetest              ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
