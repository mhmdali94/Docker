#!/bin/bash
# ============================================================
#   Don't Starve Together Server Auto-Installer
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
echo "  ║     Don't Starve Together Server Installer      ║"
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
warn "DST requires a Klei account token to authenticate."
warn "Get yours at: https://accounts.klei.com/account/info (Tools → Game Servers)"
echo ""
read -rp "  Klei server token (required): " KLEI_TOKEN
[ -z "$KLEI_TOKEN" ] && error "Klei token is required for DST servers."
read -rp "  Server/cluster name [My DST Server]: " SERVER_NAME
SERVER_NAME="${SERVER_NAME:-My DST Server}"
read -rp "  Server password (leave empty for none): " SERVER_PASS
read -rp "  Max players [6]: " MAX_PLAYERS
MAX_PLAYERS="${MAX_PLAYERS:-6}"
info "Server: $SERVER_NAME | Players: $MAX_PLAYERS"

section "Step 5: Cleaning Up Existing Containers"
for cname in dst-master dst-caves; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    [ -n "$EXISTING" ] && warn "Removing $cname..." && docker rm -f "$cname" 2>/dev/null || true
done

section "Step 6: Preparing Directory"
APP_DIR="/root/docker/dst"
mkdir -p "$APP_DIR/master/save" "$APP_DIR/master/config" "$APP_DIR/caves/save" "$APP_DIR/caves/config"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 7: Writing cluster.ini"
cat > "$APP_DIR/master/cluster.ini" <<EOF
[GAMEPLAY]
max_players = ${MAX_PLAYERS}
pvp = false
game_mode = survival
pause_when_nobody = true

[NETWORK]
cluster_name = ${SERVER_NAME}
cluster_description = Powered by Docker
cluster_password = ${SERVER_PASS}
cluster_intention = cooperative

[MISC]
console_enabled = true

[SHARD]
shard_enabled = true
bind_ip = 0.0.0.0
master_ip = dst-master
master_port = 10888
cluster_key = defaultkey
EOF
cp "$APP_DIR/master/cluster.ini" "$APP_DIR/caves/cluster.ini"
info "cluster.ini created."

echo "$KLEI_TOKEN" > "$APP_DIR/master/cluster_token.txt"
cp "$APP_DIR/master/cluster_token.txt" "$APP_DIR/caves/cluster_token.txt"

section "Step 8: Writing shard configs"
cat > "$APP_DIR/master/config/server.ini" <<EOF
[NETWORK]
server_port = 11000

[SHARD]
is_master = true
name = Master

[STEAM]
master_server_port = 27018
authentication_port = 8768
EOF

cat > "$APP_DIR/caves/config/server.ini" <<EOF
[NETWORK]
server_port = 11001

[SHARD]
is_master = false
name = Caves
master_host = dst-master
master_port = 10888
cluster_key = defaultkey
EOF

section "Step 9: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  dst-master:
    image: jamesits/dst-server:latest
    container_name: dst-master
    restart: unless-stopped
    ports:
      - "11000:11000/udp"
      - "27018:27018/udp"
    environment:
      DST_SERVER_STEM: Master
    volumes:
      - ./master:/data
    stdin_open: true
    tty: true

  dst-caves:
    image: jamesits/dst-server:latest
    container_name: dst-caves
    restart: unless-stopped
    ports:
      - "11001:11001/udp"
    environment:
      DST_SERVER_STEM: Caves
    volumes:
      - ./caves:/data
    depends_on:
      - dst-master
    stdin_open: true
    tty: true
EOF
info "docker-compose.yml created."

section "Step 10: Starting Don't Starve Together Server"
warn "Downloading DST server — first start takes 5-10 minutes..."
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start."
else
    docker-compose up -d || error "Failed to start."
fi

section "Step 11: Waiting for Server (~5 min first start)"
info "Waiting for DST server to start..."
for i in $(seq 1 18); do
    if docker logs dst-master 2>&1 | grep -q "Sim paused"; then
        info "Don't Starve Together server is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/18 — waiting 10s..."
    sleep 10
    echo " retrying"
done

section "Step 12: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 11000/udp
    ufw allow 11001/udp
    ufw allow 27018/udp
    info "UFW: DST ports opened."
else
    warn "UFW not found — skipping."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🌑  Don't Starve Together Server:                 ║"
printf  "  ║      Address: %-39s║\n" "$SERVER_IP:11000"
echo "  ║                                                      ║"
printf  "  ║      Name:       %-36s║\n" "$SERVER_NAME"
printf  "  ║      Max Players:%-36s║\n" "$MAX_PLAYERS"
[ -n "$SERVER_PASS" ] && printf "  ║      Password:   %-36s║\n" "$SERVER_PASS"
echo "  ║                                                      ║"
echo "  ║  🌍  Overworld: port 11000 | Caves: port 11001    ║"
echo "  ║  📋  Monitor: docker logs -f dst-master           ║"
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
