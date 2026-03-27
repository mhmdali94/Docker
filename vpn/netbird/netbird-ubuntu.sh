#!/bin/bash
#
# ============================================================
#   Netbird Self-Hosted Auto-Installer
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
echo "  ║       Netbird Self-Hosted Auto-Installer         ║"
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

section "Step 4: Cleaning Up Existing Containers"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^netbird' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing Netbird containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
NB_DIR="/root/docker/netbird"
if [ -d "$NB_DIR" ]; then
    warn "Removing old directory $NB_DIR..."
    rm -rf "$NB_DIR"
fi
mkdir -p "$NB_DIR"
cd "$NB_DIR" || error "Cannot navigate to $NB_DIR"
info "Directory ready: $NB_DIR"

section "Step 6: Detecting Server IP"
WAN_IP=$(curl -4 -s --max-time 5 https://ifconfig.me || curl -4 -s --max-time 5 https://api4.ipify.org || hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
info "Detected IP: $WAN_IP"

section "Step 7: Generating Credentials & docker-compose.yml"
NB_SECRET=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)

cat > "$NB_DIR/docker-compose.yml" <<EOF
services:
  netbird-signal:
    image: netbirdio/signal:latest
    container_name: netbird-signal
    restart: unless-stopped
    ports:
      - "10000:10000"
    volumes:
      - ./signal:/var/lib/netbird

  netbird-management:
    image: netbirdio/management:latest
    container_name: netbird-management
    restart: unless-stopped
    ports:
      - "8080:8080"
      - "8443:443"
    volumes:
      - ./management:/var/lib/netbird
    command: [
      "--port", "8080",
      "--log-file", "console",
      "--disable-anonymous-metrics=true",
      "--single-account-mode-domain=netbird.local",
      "--dns-domain=netbird.selfhosted"
    ]
    depends_on:
      - netbird-signal

  netbird-dashboard:
    image: netbirdio/dashboard:latest
    container_name: netbird-dashboard
    restart: unless-stopped
    ports:
      - "8089:80"
    environment:
      - AUTH_AUDIENCE=netbird
      - NETBIRD_MGMT_API_ENDPOINT=http://$WAN_IP:8080
      - NETBIRD_SIGNAL_URL=http://$WAN_IP:10000
    depends_on:
      - netbird-management
EOF
info "docker-compose.yml created."

section "Step 8: Starting Netbird"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 9: Verifying Containers"
sleep 6
RUNNING=$(docker ps --format '{{.Names}}' | grep -E 'netbird' || true)
if [ -z "$RUNNING" ]; then
    warn "Containers may not have started. Check: docker logs netbird-management"
else
    info "Containers running: $RUNNING"
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Netbird Dashboard in your browser:       ║"
echo "  ║      👉  http://$SERVER_IP:8089"
echo "  ║                                                      ║"
echo "  ║  📡  Signal Server  : $WAN_IP:10000"
echo "  ║  ⚙️   Management API : $WAN_IP:8080"
echo "  ║                                                      ║"
echo "  ║  📱  Install Netbird client on peers:               ║"
echo "  ║      https://netbird.io/downloads                   ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh | prismatechwork.com                   ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
