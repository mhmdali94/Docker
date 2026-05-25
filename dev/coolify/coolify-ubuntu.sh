#!/bin/bash
# ============================================================
#   Coolify Auto-Installer
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
echo "  ║     Coolify Auto-Installer                      ║"
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

section "Step 3: Checking curl"
if ! command -v curl &> /dev/null; then
    warn "curl not found. Installing..."
    apt update -y && apt install -y curl
    info "curl installed."
else
    info "curl: $(curl --version | head -1)"
fi

section "Step 4: Installing Coolify"
info "Running Coolify's official installer..."
echo ""
warn "Coolify manages its own Docker setup — this will install directly on the system."
warn "It deploys to port 8000 by default."
echo ""
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
info "Coolify installation complete."

section "Step 5: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 8000/tcp
    ufw allow 6001/tcp
    ufw allow 6002/tcp
    info "UFW: ports 8000, 6001, 6002 opened."
else
    warn "UFW not found — skipping."
fi

section "Step 6: Health Check"
info "Waiting for Coolify to be ready..."
for i in $(seq 1 12); do
    if curl -sf --max-time 3 http://127.0.0.1:8000 &>/dev/null; then
        info "Coolify is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🚀  Coolify:                                      ║"
echo "  ║      👉  http://$SERVER_IP:8000"
echo "  ║                                                      ║"
echo "  ║  Create your account on first visit                  ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
