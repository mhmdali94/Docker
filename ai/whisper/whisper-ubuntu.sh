#!/bin/bash
# ============================================================
#   Whisper ASR Auto-Installer
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
echo "  ║     Whisper ASR Auto-Installer                  ║"
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

section "Step 4: Model Selection"
echo ""
echo "  ┌──────────────────────────────────────────────────────┐"
echo "  │  Select Whisper model:                               │"
echo "  │                                                      │"
echo "  │  [1]  tiny    ~75 MB    Fastest, lowest accuracy    │"
echo "  │  [2]  base    ~145 MB   Good balance (recommended)  │"
echo "  │  [3]  small   ~466 MB   Better accuracy             │"
echo "  │  [4]  medium  ~1.5 GB   High accuracy               │"
echo "  │  [5]  large   ~3 GB     Best accuracy, slowest      │"
echo "  └──────────────────────────────────────────────────────┘"
echo ""
read -rp "  Your choice [1-5]: " MODEL_CHOICE
case "$MODEL_CHOICE" in
    1) ASR_MODEL="tiny"   ;;
    3) ASR_MODEL="small"  ;;
    4) ASR_MODEL="medium" ;;
    5) ASR_MODEL="large"  ;;
    *) ASR_MODEL="base"   ;;
esac
info "Model selected: $ASR_MODEL"

section "Step 5: Cleaning Up Existing Containers"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^whisper$" || true)
[ -n "$EXISTING" ] && warn "Removing existing container..." && docker rm -f whisper 2>/dev/null || true

section "Step 6: Preparing Directory"
APP_DIR="/root/docker/whisper"
mkdir -p "$APP_DIR"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 7: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  whisper:
    image: onerahmet/openai-whisper-asr-webservice:latest
    container_name: whisper
    restart: unless-stopped
    ports:
      - "9000:9000"
    environment:
      ASR_MODEL: ${ASR_MODEL}
      ASR_ENGINE: faster_whisper
    volumes:
      - ./models:/root/.cache/whisper
EOF
info "docker-compose.yml created."

section "Step 8: Starting Whisper"
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start. Run: cd $APP_DIR && docker compose up -d"
else
    docker-compose up -d || error "Failed to start. Run: cd $APP_DIR && docker-compose up -d"
fi

section "Step 9: Health Check"
info "Waiting for Whisper API (model download may take a few minutes)..."
for i in $(seq 1 18); do
    if curl -sf --max-time 3 http://127.0.0.1:9000/docs &>/dev/null; then
        info "Whisper API is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/18 — waiting 10s..."
    sleep 10
    echo " retrying"
done

section "Step 10: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 9000/tcp
    info "UFW: port 9000 opened."
else
    warn "UFW not found — skipping."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🎤  Whisper ASR API:                              ║"
echo "  ║      👉  http://$SERVER_IP:9000"
echo "  ║                                                      ║"
echo "  ║  📖  API Docs:                                     ║"
echo "  ║      👉  http://$SERVER_IP:9000/docs"
echo "  ║                                                      ║"
echo "  ║  Model: $ASR_MODEL"
echo "  ║                                                      ║"
echo "  ║  Usage: curl -X POST http://$SERVER_IP:9000/asr \\"
echo "  ║         -F 'audio_file=@audio.mp3'"
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
