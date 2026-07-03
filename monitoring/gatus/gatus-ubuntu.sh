#!/bin/bash
# ============================================================
#   Gatus Auto-Installer
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
echo "  ║     Gatus Auto-Installer                        ║"
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

section "Step 4: Cleaning Up Existing Containers"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^gatus$" || true)
[ -n "$EXISTING" ] && warn "Removing existing container..." && docker rm -f gatus 2>/dev/null || true

section "Step 5: Preparing Directory"
APP_DIR="/root/docker/gatus"
mkdir -p "$APP_DIR/config"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 6: Writing Default Config"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
cat > "$APP_DIR/config/config.yaml" <<EOF
web:
  port: 8080

storage:
  type: sqlite
  path: /data/gatus.db

endpoints:
  - name: Google
    url: https://www.google.com
    interval: 60s
    conditions:
      - "[STATUS] == 200"
      - "[RESPONSE_TIME] < 3000"

  - name: Cloudflare DNS
    url: https://1.1.1.1
    interval: 60s
    conditions:
      - "[STATUS] == 200"

  # Add your own services below:
  # - name: My Service
  #   url: http://${SERVER_IP}:8080
  #   interval: 60s
  #   conditions:
  #     - "[STATUS] == 200"
EOF
info "Default config written."

section "Step 7: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<'EOF'
services:
  gatus:
    image: twinproduction/gatus:stable
    container_name: gatus
    restart: unless-stopped
    ports:
      - "8097:8080"
    volumes:
      - ./config:/config
      - ./data:/data
EOF
info "docker-compose.yml created."

section "Step 8: Starting Gatus"
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start."
else
    docker-compose up -d || error "Failed to start."
fi

section "Step 9: Health Check"
info "Waiting for Gatus to be ready..."
for i in $(seq 1 6); do
    if curl -s --max-time 3 http://127.0.0.1:8097 &>/dev/null; then
        info "Gatus is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/6 — waiting 3s..."
    sleep 3
    echo " retrying"
done

section "Step 10: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 8097/tcp
    info "UFW: port 8097 opened."
else
    warn "UFW not found — skipping."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  📊  Gatus Status Page:                            ║"
echo "  ║      👉  http://$SERVER_IP:8097"
echo "  ║                                                      ║"
echo "  ║  📝  Config: $APP_DIR/config/config.yaml"
echo "  ║      Add your services — auto-reloads on change.   ║"
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
