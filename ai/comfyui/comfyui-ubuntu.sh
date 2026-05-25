#!/bin/bash
# ============================================================
#   ComfyUI Auto-Installer
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
echo "  ║     ComfyUI Auto-Installer                      ║"
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

section "Step 4: GPU Support (Optional)"
echo ""
echo "  ComfyUI supports NVIDIA GPU acceleration for faster image generation."
echo ""
echo "  [1]  NVIDIA GPU   (requires nvidia-container-toolkit)"
echo "  [2]  CPU only     (slow but works on any server)"
echo ""
read -rp "  Your hardware [1/2]: " HW_CHOICE
case "$HW_CHOICE" in
    1) USE_GPU=true;  info "NVIDIA GPU selected." ;;
    *) USE_GPU=false; info "CPU-only selected." ;;
esac

section "Step 5: Cleaning Up Existing Containers"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^comfyui$" || true)
[ -n "$EXISTING" ] && warn "Removing existing container..." && docker rm -f comfyui 2>/dev/null || true

section "Step 6: Preparing Directory"
APP_DIR="/root/docker/comfyui"
mkdir -p "$APP_DIR"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 7: Writing docker-compose.yml"
if [ "$USE_GPU" = true ]; then
cat > "$APP_DIR/docker-compose.yml" <<'EOF'
services:
  comfyui:
    image: yanwk/comfyui-boot:latest
    container_name: comfyui
    restart: unless-stopped
    ports:
      - "8188:8188"
    volumes:
      - ./data:/root
      - ./models:/root/ComfyUI/models
      - ./output:/root/ComfyUI/output
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
EOF
else
cat > "$APP_DIR/docker-compose.yml" <<'EOF'
services:
  comfyui:
    image: yanwk/comfyui-boot:latest
    container_name: comfyui
    restart: unless-stopped
    ports:
      - "8188:8188"
    volumes:
      - ./data:/root
      - ./models:/root/ComfyUI/models
      - ./output:/root/ComfyUI/output
EOF
fi
info "docker-compose.yml created."

section "Step 8: Starting ComfyUI"
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start. Run: cd $APP_DIR && docker compose up -d"
else
    docker-compose up -d || error "Failed to start. Run: cd $APP_DIR && docker-compose up -d"
fi

section "Step 9: Health Check"
info "Waiting for ComfyUI to be ready (first start downloads dependencies)..."
for i in $(seq 1 24); do
    if curl -sf --max-time 3 http://127.0.0.1:8188 &>/dev/null; then
        info "ComfyUI is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/24 — waiting 10s..."
    sleep 10
    echo " retrying"
done

section "Step 10: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 8188/tcp
    info "UFW: port 8188 opened."
else
    warn "UFW not found — skipping."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🎨  ComfyUI:                                      ║"
echo "  ║      👉  http://$SERVER_IP:8188"
echo "  ║                                                      ║"
echo "  ║  📁  Models directory:  $APP_DIR/models"
echo "  ║  📁  Output directory:  $APP_DIR/output"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
