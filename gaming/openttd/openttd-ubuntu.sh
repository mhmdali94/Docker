#!/bin/bash
# ============================================================
#   OpenTTD Server Auto-Installer
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
echo "  ║     OpenTTD Server Auto-Installer               ║"
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
read -rp "  Server name [My OpenTTD Server]: " SERVER_NAME
SERVER_NAME="${SERVER_NAME:-My OpenTTD Server}"
ADMIN_PASS=$(openssl rand -hex 8)
read -rp "  Admin password [$ADMIN_PASS]: " INPUT_PASS
ADMIN_PASS="${INPUT_PASS:-$ADMIN_PASS}"
read -rp "  Max companies [8]: " MAX_COMPANIES
MAX_COMPANIES="${MAX_COMPANIES:-8}"
read -rp "  Max clients [16]: " MAX_CLIENTS
MAX_CLIENTS="${MAX_CLIENTS:-16}"
info "Server: $SERVER_NAME | Companies: $MAX_COMPANIES | Clients: $MAX_CLIENTS"

section "Step 5: Cleaning Up Existing Containers"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^openttd$" || true)
[ -n "$EXISTING" ] && warn "Removing openttd..." && docker rm -f openttd 2>/dev/null || true

section "Step 6: Preparing Directory"
APP_DIR="/root/docker/openttd"
mkdir -p "$APP_DIR/data"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 7: Writing openttd.cfg"
cat > "$APP_DIR/data/openttd.cfg" <<EOF
[network]
server_name = ${SERVER_NAME}
server_advertise = true
server_password =
rcon_password = ${ADMIN_PASS}
max_companies = ${MAX_COMPANIES}
max_clients = ${MAX_CLIENTS}
max_spectators = 10
server_lang = 0
pause_on_join = true
autoclean_companies = true
autoclean_unprotected = 12
autoclean_protected = 36
autoclean_novehicles = 0
reload_cfg = true

[difficulty]
max_loan = 500000
initial_interest = 8
vehicle_costs = 0
construction_cost = 0
terrain_type = 1
land_fertility = 0
vehicle_breakdowns = 1
disasters = false
economy = 0
number_towns = 3
number_industries = 4

[game_creation]
starting_year = 1950
map_x = 9
map_y = 9
landscape = 0
EOF
info "openttd.cfg created."

section "Step 8: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  openttd:
    image: bateau/openttd:latest
    container_name: openttd
    restart: unless-stopped
    ports:
      - "3979:3979/tcp"
      - "3979:3979/udp"
      - "3978:3978/udp"
    environment:
      PUID: 1000
      PGID: 1000
      savepath: /home/openttd/.openttd/save/
      loadgame: "false"
    volumes:
      - ./data:/home/openttd/.openttd
EOF
info "docker-compose.yml created."

section "Step 9: Starting OpenTTD Server"
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start."
else
    docker-compose up -d || error "Failed to start."
fi

section "Step 10: Waiting for Server (~30s)"
info "Waiting for OpenTTD server to start..."
for i in $(seq 1 12); do
    if docker logs openttd 2>&1 | grep -q "Listening on"; then
        info "OpenTTD server is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done

section "Step 11: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 3979/tcp
    ufw allow 3979/udp
    ufw allow 3978/udp
    info "UFW: OpenTTD ports opened."
else
    warn "UFW not found — skipping."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🚂  OpenTTD Server:                               ║"
printf  "  ║      Address: %-39s║\n" "$SERVER_IP:3979"
echo "  ║                                                      ║"
printf  "  ║      Name:       %-36s║\n" "$SERVER_NAME"
printf  "  ║      RCON Pass:  %-36s║\n" "$ADMIN_PASS"
printf  "  ║      Companies:  %-36s║\n" "$MAX_COMPANIES"
echo "  ║                                                      ║"
echo "  ║  📋  Config: ./data/openttd.cfg                    ║"
echo "  ║  📋  Monitor: docker logs -f openttd               ║"
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
