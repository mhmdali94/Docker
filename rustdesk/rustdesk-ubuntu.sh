#!/bin/bash
#
# ============================================================
#   RustDesk Server Auto-Installer
#   Made by: Mohammed Ali Elshikh | prismatechwork.com
#
#   ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️
#   This script is NOT intended for production use.
#   Use it only in lab or testing environments.
# ============================================================

set -e  # Exit on error

# ------------------------------------
# Helper functions
# ------------------------------------
info()    { echo -e "\e[32m[INFO]\e[0m $*"; }
warn()    { echo -e "\e[33m[WARN]\e[0m $*"; }
error()   { echo -e "\e[31m[ERROR]\e[0m $*"; exit 1; }
section() { echo -e "\n\e[36m========== $* ==========\e[0m"; }

# ------------------------------------
# Banner
# ------------------------------------
clear
echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║       RustDesk Server Auto-Installer             ║"
echo "  ║       Made by: Mohammed Ali Elshikh | prismatechwork.com                ║"
echo "  ║                                                  ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️         ║"
echo "  ║     Not intended for production use.             ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""

# ------------------------------------
# Step 0: Root check
# ------------------------------------
section "Step 0: Checking Privileges"
if [ "$EUID" -ne 0 ]; then
    error "Please run this script as root: sudo bash $0"
fi
info "Running as root. OK."

# ------------------------------------
# Step 1: OS Verification
# ------------------------------------
section "Step 1: Verifying Operating System"
if [ ! -f /etc/os-release ]; then
    error "Cannot determine OS. Only Ubuntu 22.04 and 24.04 are supported."
fi

. /etc/os-release

if [ "$ID" != "ubuntu" ]; then
    error "Unsupported OS: $ID. Only Ubuntu is supported."
fi

if [ "$VERSION_ID" != "22.04" ] && [ "$VERSION_ID" != "24.04" ]; then
    error "Unsupported Ubuntu version: $VERSION_ID. Only 22.04 and 24.04 are supported."
fi

info "OS check passed: Ubuntu $VERSION_ID"

# ------------------------------------
# Step 2: Ensure Docker is installed
# ------------------------------------
section "Step 2: Checking Docker"
if ! command -v docker &> /dev/null; then
    warn "Docker is not installed. Installing Docker..."
    apt update -y
    apt install -y docker.io
    systemctl enable --now docker
    info "Docker installed successfully."
else
    info "Docker is already installed: $(docker --version)"
fi

# ------------------------------------
# Step 3: Ensure Docker Compose V2
# ------------------------------------
section "Step 3: Checking Docker Compose V2"
if ! docker compose version &> /dev/null; then
    warn "Docker Compose V2 not found. Installing..."
    apt update -y
    apt install -y docker-compose-v2 || apt install -y docker-compose
    info "Docker Compose installed."
else
    info "Docker Compose V2 is already installed: $(docker compose version)"
fi

# ------------------------------------
# Step 4: Ask for domain / IP
# ------------------------------------
section "Step 4: Server Address Configuration"
info "Detecting WAN IP address..."
DEFAULT_IP=$(curl -4 -s --max-time 5 ifconfig.me 2>/dev/null || curl -4 -s --max-time 5 api4.ipify.org 2>/dev/null || echo "")

if [ -z "$DEFAULT_IP" ]; then
    warn "Could not auto-detect WAN IP. You must enter it manually."
fi

read -p "  Enter your domain or IP address [$DEFAULT_IP]: " DOMAIN_OR_IP
DOMAIN_OR_IP="${DOMAIN_OR_IP:-$DEFAULT_IP}"

if [ -z "$DOMAIN_OR_IP" ]; then
    error "Domain or IP cannot be empty. Aborting."
fi

info "Using server address: $DOMAIN_OR_IP"

# ------------------------------------
# Step 5: Stop & Remove existing containers
# ------------------------------------
section "Step 5: Cleaning Up Existing RustDesk Containers"

# Find any container whose name contains hbbs or hbbr
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E 'hbbs|hbbr' || true)

if [ -n "$EXISTING" ]; then
    warn "Found existing RustDesk containers. Stopping and removing..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
    info "Containers removed."
else
    info "No existing RustDesk containers found."
fi

# Also prune any dangling networks left by old rustdesk
docker network prune -f &>/dev/null || true

# ------------------------------------
# Step 6: Clean existing directory
# ------------------------------------
section "Step 6: Preparing Installation Directory"
RUSTDESK_DIR="/root/docker/rustdesk"

if [ -d "$RUSTDESK_DIR" ]; then
    warn "Existing directory found at $RUSTDESK_DIR. Removing..."
    rm -rf "$RUSTDESK_DIR"
fi

mkdir -p "$RUSTDESK_DIR"
cd "$RUSTDESK_DIR" || error "Failed to navigate to $RUSTDESK_DIR"
info "Directory ready: $RUSTDESK_DIR"

# ------------------------------------
# Step 7: Generate docker-compose.yml
# ------------------------------------
section "Step 7: Generating docker-compose.yml"

cat > "$RUSTDESK_DIR/docker-compose.yml" <<EOF
networks:
  rustdesk-net:
    external: false

services:
  hbbs:
    container_name: hbbs
    ports:
      - 21115:21115
      - 21116:21116
      - 21116:21116/udp
      - 21118:21118
    image: rustdesk/rustdesk-server:latest
    command: hbbs -r $DOMAIN_OR_IP:21117
    volumes:
      - ./hbbs:/root
    networks:
      - rustdesk-net
    depends_on:
      - hbbr
    restart: unless-stopped

  hbbr:
    container_name: hbbr
    ports:
      - 21117:21117
      - 21119:21119
    image: rustdesk/rustdesk-server:latest
    command: hbbr
    volumes:
      - ./hbbr:/root
    networks:
      - rustdesk-net
    restart: unless-stopped
EOF

info "docker-compose.yml created successfully."

# ------------------------------------
# Step 8: Start containers
# ------------------------------------
section "Step 8: Starting RustDesk Containers"

if docker compose version &> /dev/null; then
    docker compose up -d
elif command -v docker-compose &> /dev/null; then
    docker-compose up -d
else
    error "Docker Compose not found. Cannot start containers."
fi

info "Containers started."

# ------------------------------------
# Step 9: Verify containers are running
# ------------------------------------
section "Step 9: Verifying Containers"
sleep 3

RUNNING=$(docker ps --format '{{.Names}}' | grep -E 'hbbs|hbbr' || true)
if [ -z "$RUNNING" ]; then
    warn "Containers may not have started correctly. Check logs:"
    echo "  docker logs hbbs"
    echo "  docker logs hbbr"
else
    info "Containers running: $RUNNING"
fi

# ------------------------------------
# Step 10: Display RustDesk Public Key
# ------------------------------------
section "Step 10: Retrieving RustDesk Public Key"

KEY_FILE="$RUSTDESK_DIR/hbbs/id_ed25519.pub"
info "Waiting for key file to be generated..."

WAIT=0
until [ -f "$KEY_FILE" ] || [ "$WAIT" -ge 20 ]; do
    sleep 1
    WAIT=$((WAIT + 1))
done

echo ""
if [ -f "$KEY_FILE" ]; then
    PUBKEY=$(cat "$KEY_FILE")
    echo "  ┌─────────────────────────────────────────────────────┐"
    echo "  │           🔑  Your RustDesk Public Key              │"
    echo "  ├─────────────────────────────────────────────────────┤"
    echo "  │  $PUBKEY"
    echo "  └─────────────────────────────────────────────────────┘"
    echo ""
    info "Copy the key above and paste it in your RustDesk client under:"
    info "Settings → Network → ID/Relay Server → Key"
else
    warn "Key file not found at: $KEY_FILE"
    warn "The container may still be initializing. Check again with:"
    echo "  cat $KEY_FILE"
fi

# ------------------------------------
# Done
# ------------------------------------
echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                 ║"
echo "  ║                                                  ║"
echo "  ║  Server Address : $DOMAIN_OR_IP"
echo "  ║  Directory      : $RUSTDESK_DIR"
echo "  ║                                                  ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️         ║"
echo "  ║       Made by: Mohammed Ali Elshikh | prismatechwork.com                ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""
