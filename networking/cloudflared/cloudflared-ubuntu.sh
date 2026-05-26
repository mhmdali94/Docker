#!/bin/bash
#
# ============================================================
#   Cloudflared (Cloudflare Tunnel) Auto-Installer
#   Made by: Mohammed Ali Elshikh | prismatechwork.com
#
#   ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️
#   This script is NOT intended for production use.
# ============================================================

set -e

info()    { echo -e "\e[32m[INFO]\e[0m $*"; }
warn()    { echo -e "\e[33m[WARN]\e[0m $*"; }
error()   { echo -e "\e[31m[ERROR]\e[0m $*"; exit 1; }
section() { echo -e "\n\e[36m========== $* ==========\e[0m"; }

clear
echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║    Cloudflared (Tunnel) Auto-Installer           ║"
echo "  ║    Made by: Mohammed Ali Elshikh                ║"
echo "  ║    prismatechwork.com                           ║"
echo "  ║                                                  ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️         ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║                                                      ║"
echo "  ║  ⚠️   DEMO / TESTING USE ONLY                        ║"
echo "  ║                                                      ║"
echo "  ║  This installer requires a Cloudflare Tunnel Token.  ║"
echo "  ║  Get it from: Cloudflare Zero Trust Dashboard →     ║"
echo "  ║  Networks → Tunnels → Create a Tunnel              ║"
echo "  ║                                                      ║"
echo "  ║  👨‍💻  Mohammed Ali Elshikh                            ║"
echo "  ║  🌐  prismatechwork.com                              ║"
echo "  ║                                                      ║"
echo "  ║  Press ENTER to continue...                         ║"
echo "  ║  Press Ctrl+C to cancel.                            ║"
echo "  ║                                                      ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
read -rp "" _DEMO_CONFIRM

section "Step 0: Checking Privileges"
if [ "$EUID" -ne 0 ]; then error "Please run as root: sudo bash $0"; fi
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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^cloudflared$' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing container: cloudflared"
    docker rm -f cloudflared 2>/dev/null || true
fi
docker network prune -f &>/dev/null || true

section "Step 5: Getting Tunnel Token"
echo ""
echo "  ┌──────────────────────────────────────────────────────┐"
echo "  │  Get your token from Cloudflare Zero Trust:         │"
echo "  │  https://one.dash.cloudflare.com                    │"
echo "  │  → Networks → Tunnels → Create a Tunnel             │"
echo "  │  → Copy the tunnel token shown in the setup step    │"
echo "  └──────────────────────────────────────────────────────┘"
echo ""
read -rp "  Enter your Cloudflare Tunnel Token: " TUNNEL_TOKEN
[ -z "$TUNNEL_TOKEN" ] && error "Tunnel token cannot be empty."
info "Token accepted."

section "Step 6: Preparing Directory & docker-compose.yml"
CF_DIR="/root/docker/cloudflared"
if [ -d "$CF_DIR" ]; then
    warn "Removing old directory $CF_DIR..."
    rm -rf "$CF_DIR"
fi
mkdir -p "$CF_DIR"
cd "$CF_DIR" || error "Cannot navigate to $CF_DIR"
info "Directory ready: $CF_DIR"

cat > "$CF_DIR/docker-compose.yml" <<EOF
services:
  cloudflared:
    image: cloudflare/cloudflared:latest
    container_name: cloudflared
    restart: unless-stopped
    command: tunnel --no-autoupdate run --token $TUNNEL_TOKEN
EOF
info "docker-compose.yml created."

section "Step 7: Starting Cloudflared"
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    if docker compose version &> /dev/null; then
        docker compose up -d && break
    else
        docker-compose up -d && break
    fi
    warn "Docker pull failed on attempt $attempt/$MAX_RETRIES (registry may be temporarily unavailable)."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed to start after $MAX_RETRIES attempts. Run manually: cd $PWD && docker compose up -d"
done

section "Step 8: Verifying Container"
sleep 8
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^cloudflared$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs cloudflared"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Connection Check"
info "Checking tunnel connection (may take 10-15 seconds)..."
sleep 15
LOGS=$(docker logs cloudflared 2>&1 | tail -5 || true)
if echo "$LOGS" | grep -qi "registered"; then
    info "Tunnel registered — Cloudflared is connected. ✅"
elif echo "$LOGS" | grep -qi "error"; then
    warn "Potential error in logs. Check: docker logs cloudflared"
else
    info "Cloudflared is running. Check dashboard for tunnel status."
fi

section "Step 10: No Firewall Rules Needed"
info "Cloudflared uses outbound connections only — no inbound ports required."

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Manage your tunnel in Cloudflare dashboard:   ║"
echo "  ║      https://one.dash.cloudflare.com               ║"
echo "  ║                                                      ║"
echo "  ║  📋  Check tunnel logs:                            ║"
echo "  ║      docker logs cloudflared                        ║"
echo "  ║                                                      ║"
echo "  ║  🔒  Add public hostnames in Cloudflare to route   ║"
echo "  ║      traffic to your local services.               ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║                                                      ║"
echo "  ║  🚀  Need a production-ready setup?                 ║"
echo "  ║                                                      ║"
echo "  ║  Contact us for a hardened, secure, and             ║"
echo "  ║  fully configured production environment:           ║"
echo "  ║                                                      ║"
echo "  ║  👨‍💻  Mohammed Ali Elshikh                            ║"
echo "  ║  🌐  prismatechwork.com                              ║"
echo "  ║                                                      ║"
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
