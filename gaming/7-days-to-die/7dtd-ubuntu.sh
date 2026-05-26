#!/bin/bash
# ============================================================
#   7 Days to Die Server Auto-Installer
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
echo "  ║     7 Days to Die Server Auto-Installer         ║"
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
read -rp "  Server name [My 7DTD Server]: " SERVER_NAME
SERVER_NAME="${SERVER_NAME:-My 7DTD Server}"
ADMIN_PASS=$(openssl rand -hex 8)
read -rp "  Admin password [$ADMIN_PASS]: " INPUT_PASS
ADMIN_PASS="${INPUT_PASS:-$ADMIN_PASS}"
read -rp "  Max players [8]: " MAX_PLAYERS
MAX_PLAYERS="${MAX_PLAYERS:-8}"
read -rp "  Game world (Navezgane/RWG) [Navezgane]: " GAME_WORLD
GAME_WORLD="${GAME_WORLD:-Navezgane}"
info "Server: $SERVER_NAME | World: $GAME_WORLD | Players: $MAX_PLAYERS"

section "Step 5: Cleaning Up Existing Containers"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^7dtd$" || true)
[ -n "$EXISTING" ] && warn "Removing 7dtd..." && docker rm -f 7dtd 2>/dev/null || true

section "Step 6: Preparing Directory"
APP_DIR="/root/docker/7dtd"
mkdir -p "$APP_DIR/data" "$APP_DIR/config"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 7: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  7dtd:
    image: linuxserver/7dtd:latest
    container_name: 7dtd
    restart: unless-stopped
    ports:
      - "26900:26900/tcp"
      - "26900:26900/udp"
      - "26901:26901/udp"
      - "26902:26902/udp"
      - "8080:8080/tcp"
      - "8082:8082/tcp"
    environment:
      PUID: 1000
      PGID: 1000
      TZ: UTC
      START_MODE: 0
      VERSION: stable
      SERVERCONFIG: serverconfig.xml
    volumes:
      - ./data:/config
EOF
info "docker-compose.yml created."

section "Step 8: Writing serverconfig.xml"
cat > "$APP_DIR/data/serverconfig.xml" <<EOF
<?xml version="1.0"?>
<ServerSettings>
  <property name="ServerName"              value="${SERVER_NAME}"/>
  <property name="ServerDescription"      value="Powered by Docker"/>
  <property name="ServerWebsiteURL"       value=""/>
  <property name="ServerPassword"         value=""/>
  <property name="ServerLoginConfirmationText" value=""/>
  <property name="Region"                 value="NorthAmericaEast"/>
  <property name="Language"               value="English"/>
  <property name="ServerPort"             value="26900"/>
  <property name="ServerVisibility"       value="2"/>
  <property name="ServerDisabledNetworkProtocols" value="SteamNetworking"/>
  <property name="ServerMaxWorldTransferSpeedKiBs" value="512"/>
  <property name="HideCommandExecutionLog" value="0"/>
  <property name="MaxUncoveredMapChunksPerPlayer" value="131072"/>
  <property name="PersistentPlayerProfiles" value="false"/>
  <property name="GameWorld"              value="${GAME_WORLD}"/>
  <property name="WorldGenSeed"           value="asdf"/>
  <property name="WorldGenSize"           value="6144"/>
  <property name="GameName"              value="MyGame"/>
  <property name="GameMode"              value="GameModeSurvival"/>
  <property name="UserDataFolder"         value="saves"/>
  <property name="MaxSpawnedZombies"      value="64"/>
  <property name="MaxSpawnedAnimals"      value="50"/>
  <property name="ServerMaxPlayerCount"   value="${MAX_PLAYERS}"/>
  <property name="ServerReservedSlots"    value="0"/>
  <property name="ServerReservedSlotsPermission" value="100"/>
  <property name="ServerAdminSlots"       value="0"/>
  <property name="ServerAdminSlotsPermission" value="0"/>
  <property name="ControlPanelEnabled"    value="true"/>
  <property name="ControlPanelPort"       value="8080"/>
  <property name="ControlPanelPassword"   value="${ADMIN_PASS}"/>
  <property name="TelnetEnabled"          value="true"/>
  <property name="TelnetPort"             value="8081"/>
  <property name="TelnetPassword"         value="${ADMIN_PASS}"/>
  <property name="WebDashboardEnabled"    value="true"/>
  <property name="WebDashboardPort"       value="8082"/>
  <property name="WebDashboardUrl"        value=""/>
  <property name="EacEnabled"             value="false"/>
  <property name="HideCommandExecutionLog" value="0"/>
  <property name="SaveGameFolder"         value="saves"/>
  <property name="AdminFileName"          value="serveradmin.xml"/>
  <property name="XmlFiles"              value=""/>
</ServerSettings>
EOF
info "serverconfig.xml created."

section "Step 9: Starting 7 Days to Die Server"
warn "Downloading 7DTD server (~8 GB) — first start takes 15-30 minutes..."
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start."
else
    docker-compose up -d || error "Failed to start."
fi

section "Step 10: Waiting for Server (~20 min first start)"
info "Waiting for 7DTD server to start..."
for i in $(seq 1 36); do
    if docker logs 7dtd 2>&1 | grep -q "GameServer.Init successful"; then
        info "7 Days to Die server is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/36 — waiting 10s..."
    sleep 10
    echo " retrying"
done

section "Step 11: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 26900/tcp
    ufw allow 26900/udp
    ufw allow 26901/udp
    ufw allow 26902/udp
    ufw allow 8080/tcp
    ufw allow 8082/tcp
    info "UFW: 7DTD ports opened."
else
    warn "UFW not found — skipping."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🧟  7 Days to Die Server:                         ║"
printf  "  ║      Address: %-39s║\n" "$SERVER_IP:26900"
echo "  ║                                                      ║"
printf  "  ║      Name:       %-36s║\n" "$SERVER_NAME"
printf  "  ║      World:      %-36s║\n" "$GAME_WORLD"
printf  "  ║      Admin Pass: %-36s║\n" "$ADMIN_PASS"
echo "  ║                                                      ║"
echo "  ║  🖥️   Control Panel: http://$SERVER_IP:8080"
echo "  ║  📊  Dashboard:     http://$SERVER_IP:8082"
echo "  ║  📋  Monitor: docker logs -f 7dtd                  ║"
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
