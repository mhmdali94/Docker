#!/bin/bash
# ============================================================
#   Rocket.Chat Auto-Installer
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
echo "  ║     Rocket.Chat Auto-Installer                  ║"
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

section "Step 4: Generating Secrets"
MONGO_PASS=$(openssl rand -hex 16)
info "Database password generated."

section "Step 5: Cleaning Up Existing Containers"
for cname in rocketchat rocketchat-mongodb mongo-init-replica; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    [ -n "$EXISTING" ] && warn "Removing $cname..." && docker rm -f "$cname" 2>/dev/null || true
done

section "Step 6: Preparing Directory"
APP_DIR="/root/docker/rocketchat"
mkdir -p "$APP_DIR"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 7: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  rocketchat:
    image: rocket.chat:latest
    container_name: rocketchat
    restart: unless-stopped
    ports:
      - "3100:3000"
    environment:
      MONGO_URL: mongodb://rocketchat:${MONGO_PASS}@rocketchat-mongodb:27017/rocketchat?authSource=admin
      MONGO_OPLOG_URL: mongodb://rocketchat:${MONGO_PASS}@rocketchat-mongodb:27017/local?authSource=admin
      ROOT_URL: http://localhost:3100
      PORT: "3000"
    volumes:
      - ./uploads:/app/uploads
    depends_on:
      - rocketchat-mongodb

  rocketchat-mongodb:
    image: mongo:5.0
    container_name: rocketchat-mongodb
    restart: unless-stopped
    command: mongod --oplogSize 128 --replSet rs0
    volumes:
      - ./data/mongodb:/data/db
    environment:
      MONGO_INITDB_ROOT_USERNAME: rocketchat
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_PASS}

  mongo-init-replica:
    image: mongo:5.0
    container_name: mongo-init-replica
    command: >
      bash -c "sleep 15 && mongosh --host rocketchat-mongodb -u rocketchat -p ${MONGO_PASS} --authenticationDatabase admin --eval \"rs.initiate({_id: 'rs0', members: [{_id: 0, host: 'rocketchat-mongodb:27017'}]})\""
    depends_on:
      - rocketchat-mongodb
    restart: on-failure
EOF
info "docker-compose.yml created."

section "Step 8: Starting Rocket.Chat"
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start. Run: cd $APP_DIR && docker compose up -d"
else
    docker-compose up -d || error "Failed to start. Run: cd $APP_DIR && docker-compose up -d"
fi

section "Step 9: Health Check"
info "Waiting for Rocket.Chat to be ready (takes ~60s)..."
for i in $(seq 1 18); do
    if curl -s --max-time 3 http://127.0.0.1:3100 &>/dev/null; then
        info "Rocket.Chat is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/18 — waiting 10s..."
    sleep 10
    echo " retrying"
done

section "Step 10: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 3100/tcp
    info "UFW: port 3100 opened."
else
    warn "UFW not found — skipping."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  💬  Rocket.Chat:                                  ║"
echo "  ║      👉  http://$SERVER_IP:3100"
echo "  ║                                                      ║"
echo "  ║  First user to register becomes admin               ║"
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
