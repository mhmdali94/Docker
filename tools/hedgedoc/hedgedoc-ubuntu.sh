#!/bin/bash
# ============================================================
#   HedgeDoc Auto-Installer
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
echo "  ║     HedgeDoc Auto-Installer                     ║"
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
SERVER_IP_DEFAULT=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
read -rp "  Enter your server IP or domain [$SERVER_IP_DEFAULT]: " SERVER_ADDR
SERVER_ADDR="${SERVER_ADDR:-$SERVER_IP_DEFAULT}"
DB_PASS=$(openssl rand -hex 16)
SESSION_SECRET=$(openssl rand -hex 32)
info "Using server: $SERVER_ADDR"

section "Step 5: Cleaning Up Existing Containers"
for cname in hedgedoc hedgedoc-postgres; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    [ -n "$EXISTING" ] && warn "Removing $cname..." && docker rm -f "$cname" 2>/dev/null || true
done

section "Step 6: Preparing Directory"
APP_DIR="/root/docker/hedgedoc"
mkdir -p "$APP_DIR"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 7: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  hedgedoc:
    image: quay.io/hedgedoc/hedgedoc:latest
    container_name: hedgedoc
    restart: unless-stopped
    ports:
      - "3888:3000"
    environment:
      CMD_DB_URL: postgres://hedgedoc:${DB_PASS}@hedgedoc-postgres:5432/hedgedoc
      CMD_DOMAIN: ${SERVER_ADDR}
      CMD_PORT: 3000
      CMD_URL_ADDPORT: "true"
      CMD_PROTOCOL_USESSL: "false"
      CMD_SESSION_SECRET: ${SESSION_SECRET}
      CMD_ALLOW_ANONYMOUS: "true"
      CMD_ALLOW_ANONYMOUS_EDITS: "true"
      CMD_ALLOW_FREEURL: "true"
    volumes:
      - ./uploads:/hedgedoc/public/uploads
    depends_on:
      - hedgedoc-postgres

  hedgedoc-postgres:
    image: postgres:15-alpine
    container_name: hedgedoc-postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: hedgedoc
      POSTGRES_USER: hedgedoc
      POSTGRES_PASSWORD: ${DB_PASS}
    volumes:
      - ./postgres:/var/lib/postgresql/data
EOF
info "docker-compose.yml created."

section "Step 8: Starting HedgeDoc"
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start. Run: cd $APP_DIR && docker compose up -d"
else
    docker-compose up -d || error "Failed to start. Run: cd $APP_DIR && docker-compose up -d"
fi

section "Step 9: Health Check"
info "Waiting for HedgeDoc to be ready..."
for i in $(seq 1 12); do
    if curl -s --max-time 3 http://127.0.0.1:3888 &>/dev/null; then
        info "HedgeDoc is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done

section "Step 10: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 3888/tcp
    info "UFW: port 3888 opened."
else
    warn "UFW not found — skipping."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  📝  HedgeDoc:                                     ║"
echo "  ║      👉  http://$SERVER_ADDR:3888"
echo "  ║                                                      ║"
echo "  ║  📄  New note:  http://$SERVER_ADDR:3888/new"
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
