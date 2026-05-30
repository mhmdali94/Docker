#!/bin/bash
# ============================================================
#   Kasm Workspaces Auto-Installer
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
echo "  ║     Kasm Workspaces Auto-Installer              ║"
echo "  ║     Made by: Mohammed Ali Elshikh              ║"
echo "  ║     prismatechwork.com                         ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️        ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""
echo "  ⚠️  Kasm requires port 443 — ensure it is free."
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
if ! command -v docker &>/dev/null; then
    warn "Docker not found. Installing..."
    apt update -y && apt install -y docker.io
    systemctl enable --now docker
    info "Docker installed."
else
    info "Docker: $(docker --version)"
fi

section "Step 3: Checking Docker Compose V2"
if ! docker compose version &>/dev/null; then
    warn "Docker Compose V2 not found. Installing..."
    apt update -y && apt install -y docker-compose-v2 || apt install -y docker-compose
    info "Docker Compose installed."
else
    info "Docker Compose: $(docker compose version)"
fi

section "Step 4: Cleaning Up Existing Containers"
for cname in kasm; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    [ -n "$EXISTING" ] && warn "Removing $cname..." && docker rm -f "$cname" 2>/dev/null || true
done

section "Step 5: Preparing Directory"
APP_DIR="/root/docker/kasm"
mkdir -p "$APP_DIR"/{opt,profiles}
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 6: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<'EOF'
services:
  kasm:
    image: kasmweb/kasm:1.15.0
    container_name: kasm
    restart: unless-stopped
    privileged: true
    ports:
      - "443:443"
    volumes:
      - ./opt:/opt
      - ./profiles:/profiles
EOF
info "docker-compose.yml created."

section "Step 7: Starting Kasm Workspaces"
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    if docker compose version &>/dev/null; then
        docker compose up -d && break
    else
        docker-compose up -d && break
    fi
    warn "Attempt $attempt/$MAX_RETRIES failed."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed after $MAX_RETRIES attempts."
done

section "Step 8: Health Check"
info "Waiting for Kasm on port 443 (may take 2-3 min)..."
HEALTH_OK=0
for i in $(seq 1 18); do
    if curl -sk --max-time 5 https://127.0.0.1:443 &>/dev/null; then
        info "Port 443 is responding. ✅"; HEALTH_OK=1; break
    fi
    echo -n "  Attempt $i/18 — waiting 10s..."; sleep 10; echo " retrying"
done
[ "$HEALTH_OK" -eq 0 ] && warn "Not responding. Check: docker logs kasm"

section "Step 9: Opening Firewall"
if command -v ufw &>/dev/null; then
    ufw allow 443/tcp; info "UFW: port 443 opened."
else
    warn "UFW not found — skipping."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🖥️  Kasm Workspaces (Browser Desktops):           ║"
echo "  ║      👉  https://$SERVER_IP"
echo "  ║                                                      ║"
echo "  ║  🔑  Default login:                                ║"
echo "  ║      admin@kasm.local / admin                      ║"
echo "  ║      Change immediately after first login!         ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  Accept the self-signed cert warning.          ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║  🚀  Need production setup?                         ║"
echo "  ║      👨‍💻  Mohammed Ali Elshikh                      ║"
echo "  ║      🌐  prismatechwork.com                         ║"
echo "  ║  ☕  USDT (TRC-20): TCSZTkXvhibdrFre5sdTsFLRQ6d6yQkd2i ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
