#!/bin/bash
# ============================================================
#   Project Zomboid Server Auto-Installer
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
echo "  ║     Project Zomboid Server Auto-Installer       ║"
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
read -rp "  Server name [My PZ Server]: " SERVER_NAME
SERVER_NAME="${SERVER_NAME:-My PZ Server}"
ADMIN_PASS=$(openssl rand -hex 8)
read -rp "  Admin password [$ADMIN_PASS]: " INPUT_PASS
ADMIN_PASS="${INPUT_PASS:-$ADMIN_PASS}"
read -rp "  Max players [16]: " MAX_PLAYERS
MAX_PLAYERS="${MAX_PLAYERS:-16}"
info "Server: $SERVER_NAME | Max players: $MAX_PLAYERS"

section "Step 5: Cleaning Up Existing Containers"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^project-zomboid$" || true)
[ -n "$EXISTING" ] && warn "Removing project-zomboid..." && docker rm -f project-zomboid 2>/dev/null || true

section "Step 6: Preparing Directory"
APP_DIR="/root/docker/project-zomboid"
mkdir -p "$APP_DIR/data"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 7: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  project-zomboid:
    image: linuxserver/projectzomboid:latest
    container_name: project-zomboid
    restart: unless-stopped
    ports:
      - "16261:16261/udp"
      - "16262:16262/udp"
    environment:
      PUID: 1000
      PGID: 1000
      TZ: UTC
      VERSION: public
    volumes:
      - ./data:/config
    stdin_open: true
    tty: true
EOF
info "docker-compose.yml created."

section "Step 8: Starting Project Zomboid Server"
warn "Downloading Project Zomboid server — first start takes 5-10 minutes..."
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start."
else
    docker-compose up -d || error "Failed to start."
fi

info "Waiting 60s for server files to be created before configuring..."
sleep 60

section "Step 9: Configuring Server"
SERVER_INI="$APP_DIR/data/Server/servertest.ini"
if [ -f "$SERVER_INI" ]; then
    sed -i "s/^PublicName=.*/PublicName=${SERVER_NAME}/" "$SERVER_INI" 2>/dev/null || true
    sed -i "s/^MaxPlayers=.*/MaxPlayers=${MAX_PLAYERS}/" "$SERVER_INI" 2>/dev/null || true
    info "Server config updated."
else
    warn "Server config not yet created — configure manually in $SERVER_INI"
fi

# Set admin password
docker exec project-zomboid /bin/bash -c "echo \"${ADMIN_PASS}\" | /app/projectzomboid/ProjectZomboid64 -nosteam -adminpassword \"${ADMIN_PASS}\"" 2>/dev/null || true
docker restart project-zomboid 2>/dev/null || true

section "Step 10: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 16261/udp
    ufw allow 16262/udp
    info "UFW: ports 16261 and 16262 UDP opened."
else
    warn "UFW not found — skipping."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🧟  Project Zomboid Server:                       ║"
printf  "  ║      Address: %-39s║\n" "$SERVER_IP:16261"
echo "  ║                                                      ║"
printf  "  ║      Name:       %-36s║\n" "$SERVER_NAME"
printf  "  ║      Admin Pass: %-36s║\n" "$ADMIN_PASS"
printf  "  ║      Max Players:%-36s║\n" "$MAX_PLAYERS"
echo "  ║                                                      ║"
echo "  ║  📋  Server files: ./data/Server/                  ║"
echo "  ║  📋  Monitor: docker logs -f project-zomboid       ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
