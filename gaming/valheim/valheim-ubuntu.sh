#!/bin/bash
# ============================================================
#   Valheim Server Auto-Installer
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
echo "  ║     Valheim Server Auto-Installer               ║"
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
read -rp "  Server name [My Valheim Server]: " SERVER_NAME
SERVER_NAME="${SERVER_NAME:-My Valheim Server}"
read -rp "  World name [MyWorld]: " WORLD_NAME
WORLD_NAME="${WORLD_NAME:-MyWorld}"
read -rp "  Server password (min 5 chars) [valheim123]: " SERVER_PASS
SERVER_PASS="${SERVER_PASS:-valheim123}"
info "Server: $SERVER_NAME | World: $WORLD_NAME"

section "Step 5: Cleaning Up Existing Containers"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^valheim$" || true)
[ -n "$EXISTING" ] && warn "Removing valheim..." && docker rm -f valheim 2>/dev/null || true

section "Step 6: Preparing Directory"
APP_DIR="/root/docker/valheim"
mkdir -p "$APP_DIR/data" "$APP_DIR/config"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 7: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  valheim:
    image: lloesche/valheim-server:latest
    container_name: valheim
    restart: unless-stopped
    ports:
      - "2456:2456/udp"
      - "2457:2457/udp"
      - "2458:2458/udp"
    environment:
      SERVER_NAME: "${SERVER_NAME}"
      WORLD_NAME: "${WORLD_NAME}"
      SERVER_PASS: "${SERVER_PASS}"
      SERVER_PUBLIC: "true"
      UPDATE_CRON: "0 4 * * *"
      BACKUPS: "true"
      BACKUPS_CRON: "0 3 * * *"
      BACKUPS_MAX_AGE: 3
    volumes:
      - ./config:/config
      - ./data:/opt/valheim/data
    cap_add:
      - sys_nice
EOF
info "docker-compose.yml created."

section "Step 8: Starting Valheim Server"
warn "Downloading Valheim server via SteamCMD — first start takes 5-10 minutes..."
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start."
else
    docker-compose up -d || error "Failed to start."
fi

section "Step 9: Waiting for Server (~5 min first start)"
info "Waiting for Valheim server to start..."
for i in $(seq 1 36); do
    if docker logs valheim 2>&1 | grep -q "Game server connected"; then
        info "Valheim server is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/36 — waiting 10s..."
    sleep 10
    echo " retrying"
done

section "Step 10: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 2456/udp
    ufw allow 2457/udp
    ufw allow 2458/udp
    info "UFW: ports 2456-2458 UDP opened."
else
    warn "UFW not found — skipping."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🛡️   Valheim Server:                              ║"
printf  "  ║      Address: %-39s║\n" "$SERVER_IP:2456"
echo "  ║                                                      ║"
printf  "  ║      Server: %-40s║\n" "$SERVER_NAME"
printf  "  ║      World:  %-40s║\n" "$WORLD_NAME"
printf  "  ║      Pass:   %-40s║\n" "$SERVER_PASS"
echo "  ║                                                      ║"
echo "  ║  📋  Monitor: docker logs -f valheim               ║"
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
