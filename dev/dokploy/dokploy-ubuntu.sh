#!/bin/bash
# ============================================================
#   Dokploy Auto-Installer
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
echo "  ║   Dokploy Auto-Installer"
echo "  ║   Made by: Mohammed Ali Elshikh"
echo "  ║   prismatechwork.com"
echo "  ║"
echo "  ║   ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║  ⚠️   DEMO / TESTING USE ONLY                        ║"
echo "  ║  Dokploy initializes Docker Swarm and needs ports   ║"
echo "  ║  80, 443 and 3000 to be free on this server.        ║"
echo "  ║  Press ENTER to continue... Ctrl+C to cancel.       ║"
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

section "Step 2: Checking Ports"
for p in 80 443 3000; do
    if ss -ltn 2>/dev/null | grep -q ":$p "; then
        error "Port $p is already in use — Dokploy requires it. Free the port and re-run."
    fi
done
info "Ports 80, 443 and 3000 are free."

section "Step 3: Checking curl"
if ! command -v curl &> /dev/null; then
    warn "curl not found. Installing..."
    apt update -y && apt install -y curl
fi
info "curl available."

section "Step 4: Running the Official Dokploy Installer"
warn "This installs Docker (if missing), initializes Docker Swarm, and starts Dokploy."
curl -sSL https://dokploy.com/install.sh | sh || error "Dokploy installer failed. Check output above."

section "Step 5: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw allow 3000/tcp
    info "UFW: ports 80, 443 and 3000 opened."
else
    warn "UFW not found — skipping firewall rules."
fi

section "Step 6: Health Check"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
info "Waiting for Dokploy on port 3000..."
HEALTH_OK=0
for i in $(seq 1 36); do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://127.0.0.1:3000 2>/dev/null || echo "000")
    if [ "$STATUS" != "000" ]; then
        info "Dokploy is responding (HTTP $STATUS). ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/36 — waiting 10s..."
    sleep 10
    echo " retrying"
done
[ "$HEALTH_OK" -eq 0 ] && warn "Not responding yet. Check: docker service logs dokploy"

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🚀  Dokploy:  http://$SERVER_IP:3000"
echo "  ║  🔧  Create the admin account on first visit."
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
