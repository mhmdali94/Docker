#!/bin/bash
# ============================================================
#   Sentry (self-hosted) Auto-Installer
#   Made by: Mohammed Ali Elshikh | prismatechwork.com
#   ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️
# ============================================================
set -e

info()    { echo -e "\e[32m[INFO]\e[0m $*"; }
warn()    { echo -e "\e[33m[WARN]\e[0m $*"; }
error()   { echo -e "\e[31m[ERROR]\e[0m $*"; exit 1; }
section() { echo -e "\n\e[36m========== $* ==========\e[0m"; }

clear
echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║   Sentry (self-hosted) Auto-Installer"
echo "  ║   Made by: Mohammed Ali Elshikh"
echo "  ║   prismatechwork.com"
echo "  ║"
echo "  ║   ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║  ⚠️   HEAVY STACK WARNING                            ║"
echo "  ║  Sentry self-hosted runs 40+ containers and needs   ║"
echo "  ║  at least 16 GB RAM and 20 GB free disk space.      ║"
echo "  ║  Press ENTER to continue... Ctrl+C to cancel.       ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
read -rp "" _DEMO_CONFIRM

section "Step 0: Checking Privileges & Resources"
if [ "$EUID" -ne 0 ]; then error "Please run as root: sudo bash $0"; fi
TOTAL_RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
if [ "$TOTAL_RAM_GB" -lt 15 ]; then
    warn "Only ${TOTAL_RAM_GB} GB RAM detected — Sentry recommends 16 GB. Continuing anyway..."
fi
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

section "Step 3: Checking Docker Compose V2 & git"
if ! docker compose version &> /dev/null; then
    warn "Docker Compose V2 not found. Installing..."
    apt update -y && apt install -y docker-compose-v2 || apt install -y docker-compose
fi
if ! command -v git &> /dev/null; then
    apt update -y && apt install -y git
fi
info "Docker Compose: $(docker compose version)"

section "Step 4: Cleaning Up Existing Deployment"
SERVICE_DIR="/root/docker/sentry"
if [ -d "$SERVICE_DIR" ]; then
    warn "Stopping existing Sentry stack..."
    (cd "$SERVICE_DIR" && docker compose down --remove-orphans 2>/dev/null) || true
    warn "Removing existing configuration at $SERVICE_DIR..."
    rm -rf "$SERVICE_DIR"
fi
docker network prune -f &>/dev/null || true
info "Cleanup complete."

section "Step 5: Fetching Sentry Self-Hosted"
git clone --depth 1 https://github.com/getsentry/self-hosted.git "$SERVICE_DIR" || error "Failed to clone getsentry/self-hosted."
cd "$SERVICE_DIR" || error "Cannot navigate to $SERVICE_DIR"
info "Sources ready: $SERVICE_DIR"

section "Step 6: Configuring Port"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
if grep -q '^SENTRY_BIND=' .env; then
    sed -i 's|^SENTRY_BIND=.*|SENTRY_BIND=9002|' .env
else
    echo "SENTRY_BIND=9002" >> .env
fi
info "Sentry web will listen on port 9002."

section "Step 7: Running the Official Installer (takes 10-30 minutes)"
warn "This pulls and builds many images. Grab a coffee."
./install.sh --skip-user-creation --no-report-self-hosted-issues || error "Sentry install.sh failed. Check output above."

section "Step 8: Starting Sentry"
docker compose up -d --wait || docker compose up -d || error "Failed to start Sentry."

section "Step 9: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    ufw allow 9002/tcp
    info "UFW: port 9002/tcp opened."
else
    warn "UFW not found — skipping firewall rules."
fi

section "Step 10: Health Check"
info "Waiting for Sentry on port 9002..."
HEALTH_OK=0
for i in $(seq 1 48); do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://127.0.0.1:9002 2>/dev/null || echo "000")
    if [ "$STATUS" != "000" ]; then
        info "Sentry is responding (HTTP $STATUS). ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/48 — waiting 10s..."
    sleep 10
    echo " retrying"
done
[ "$HEALTH_OK" -eq 0 ] && warn "Not responding yet. Check: cd $SERVICE_DIR && docker compose logs web"

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🛰️   Sentry:  http://$SERVER_IP:9002"
echo "  ║"
echo "  ║  ➕  Create the admin user:"
echo "  ║      cd $SERVICE_DIR && docker compose run --rm web createuser"
echo "  ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️"
echo "  ║       Made by: Mohammed Ali Elshikh"
echo "  ║       prismatechwork.com"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║  🚀  Need production setup?                         ║"
echo "  ║      👨‍💻  Mohammed Ali Elshikh | prismatechwork.com"
echo "  ║  ☕  USDT (TRC-20): TCSZTkXvhibdrFre5sdTsFLRQ6d6yQkd2i"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
