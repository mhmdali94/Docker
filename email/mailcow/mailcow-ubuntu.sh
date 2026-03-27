#!/bin/bash
#
# ============================================================
#   Mailcow Email Suite Auto-Installer
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
echo "  ║       Mailcow Email Suite Auto-Installer         ║"
echo "  ║       Made by: Mohammed Ali Elshikh | prismatechwork.com                ║"
echo "  ║                                                  ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️         ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""

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

section "Step 4: Checking Git"
if ! command -v git &> /dev/null; then
    warn "Git not found. Installing..."
    apt update -y && apt install -y git
    info "Git installed."
else
    info "Git: $(git --version)"
fi

section "Step 5: Cleaning Up Existing Installation"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E 'mailcow' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing Mailcow containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
fi
docker network prune -f &>/dev/null || true

section "Step 6: Preparing Directory"
MC_DIR="/root/docker/mailcow"
if [ -d "$MC_DIR" ]; then
    warn "Removing old directory $MC_DIR..."
    rm -rf "$MC_DIR"
fi
mkdir -p "$MC_DIR"
cd "$MC_DIR" || error "Cannot navigate to $MC_DIR"
info "Directory ready: $MC_DIR"

section "Step 7: Detecting Server IP & Hostname"
WAN_IP=$(curl -4 -s --max-time 5 https://ifconfig.me || curl -4 -s --max-time 5 https://api4.ipify.org || hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
MAIL_HOSTNAME="mail.example.com"
info "Detected WAN IP: $WAN_IP"
warn "Using placeholder hostname: $MAIL_HOSTNAME"
warn "Change MAILCOW_HOSTNAME in mailcow.conf before starting in production!"

section "Step 8: Cloning Mailcow Repository"
git clone https://github.com/mailcow/mailcow-dockerized.git "$MC_DIR/mailcow-dockerized"
cd "$MC_DIR/mailcow-dockerized" || error "Cannot navigate to mailcow-dockerized"
info "Repository cloned."

section "Step 9: Generating Mailcow Config"
MAILCOW_HOSTNAME="$MAIL_HOSTNAME" ./generate_config.sh
info "mailcow.conf generated."

section "Step 10: Starting Mailcow"
if docker compose version &> /dev/null; then
    docker compose pull
    docker compose up -d
else
    docker-compose pull
    docker-compose up -d
fi

section "Step 11: Verifying Containers"
sleep 10
RUNNING=$(docker ps --format '{{.Names}}' | grep -E 'mailcow' || true)
if [ -z "$RUNNING" ]; then
    warn "Containers may not have started. Check: docker compose logs"
else
    info "Containers running: $(echo "$RUNNING" | wc -l) mailcow services"
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Mailcow Admin UI in your browser:        ║"
echo "  ║      👉  https://$SERVER_IP"
echo "  ║                                                      ║"
echo "  ║  🔑  Default Login Credentials:                     ║"
echo "  ║      Username : admin                               ║"
echo "  ║      Password : moohoo                              ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  Change the admin password immediately!         ║"
echo "  ║                                                      ║"
echo "  ║  📧  Services included:                             ║"
echo "  ║      • Postfix  (SMTP)   → port 25, 587, 465       ║"
echo "  ║      • Dovecot (IMAP)   → port 143, 993            ║"
echo "  ║      • SOGo   (Webmail) → https://IP/SOGo          ║"
echo "  ║      • Rspamd (Spam)    → https://IP/rspamd        ║"
echo "  ║                                                      ║"
echo "  ║  📁  Config dir: $MC_DIR/mailcow-dockerized"
echo "  ║                                                      ║"
echo "  ║  ⚠️  A real domain + DNS records are required       ║"
echo "  ║      for production email delivery.                 ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh | prismatechwork.com                   ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
