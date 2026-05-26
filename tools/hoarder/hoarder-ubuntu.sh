#!/bin/bash
# ============================================================
#   Hoarder Auto-Installer
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
echo "  ║     Hoarder Auto-Installer                      ║"
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
NEXTAUTH_SECRET=$(openssl rand -hex 32)
MEILI_MASTER_KEY=$(openssl rand -hex 24)
echo ""
echo "  Hoarder can use an AI API (OpenAI or Ollama) to auto-tag bookmarks."
echo "  Leave blank to disable AI tagging."
echo ""
read -rp "  Enter OpenAI API key (or press ENTER to skip): " OPENAI_KEY
if [ -z "$OPENAI_KEY" ]; then
    warn "No OpenAI key — AI tagging disabled."
    OPENAI_ENV=""
else
    OPENAI_ENV="OPENAI_API_KEY=${OPENAI_KEY}"
    info "OpenAI key set."
fi

section "Step 5: Cleaning Up Existing Containers"
for cname in hoarder hoarder-meilisearch hoarder-chrome; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    [ -n "$EXISTING" ] && warn "Removing $cname..." && docker rm -f "$cname" 2>/dev/null || true
done

section "Step 6: Preparing Directory"
APP_DIR="/root/docker/hoarder"
mkdir -p "$APP_DIR"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 7: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  hoarder:
    image: ghcr.io/hoarder-app/hoarder:release
    container_name: hoarder
    restart: unless-stopped
    ports:
      - "3777:3000"
    volumes:
      - ./data:/data
    environment:
      NEXTAUTH_SECRET: ${NEXTAUTH_SECRET}
      NEXTAUTH_URL: http://localhost:3777
      DATA_DIR: /data
      MEILI_ADDR: http://hoarder-meilisearch:7700
      MEILI_MASTER_KEY: ${MEILI_MASTER_KEY}
      BROWSER_WEB_URL: http://hoarder-chrome:9222
      ${OPENAI_ENV}
    depends_on:
      - hoarder-meilisearch
      - hoarder-chrome

  hoarder-meilisearch:
    image: getmeili/meilisearch:v1.6
    container_name: hoarder-meilisearch
    restart: unless-stopped
    environment:
      MEILI_MASTER_KEY: ${MEILI_MASTER_KEY}
      MEILI_NO_ANALYTICS: "true"
    volumes:
      - ./meilisearch:/meili_data

  hoarder-chrome:
    image: gcr.io/zenika-hub/alpine-chrome:123
    container_name: hoarder-chrome
    restart: unless-stopped
    command: --no-sandbox --disable-gpu --remote-debugging-address=0.0.0.0 --remote-debugging-port=9222
EOF
info "docker-compose.yml created."

section "Step 8: Starting Hoarder"
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start. Run: cd $APP_DIR && docker compose up -d"
else
    docker-compose up -d || error "Failed to start. Run: cd $APP_DIR && docker-compose up -d"
fi

section "Step 9: Health Check"
info "Waiting for Hoarder to be ready..."
for i in $(seq 1 12); do
    if curl -s --max-time 3 http://127.0.0.1:3777 &>/dev/null; then
        info "Hoarder is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done

section "Step 10: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 3777/tcp
    info "UFW: port 3777 opened."
else
    warn "UFW not found — skipping."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🗂️   Hoarder:                                      ║"
echo "  ║      👉  http://$SERVER_IP:3777"
echo "  ║                                                      ║"
echo "  ║  📝  First visit: create your admin account         ║"
echo "  ║  🏷️   AI tagging: $([ -n "$OPENAI_KEY" ] && echo "Enabled (OpenAI)" || echo "Disabled")"
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
