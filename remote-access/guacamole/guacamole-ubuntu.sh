#!/bin/bash
#
# ============================================================
#   Apache Guacamole Auto-Installer
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
echo "  ║      Apache Guacamole Auto-Installer             ║"
echo "  ║      Made by: Mohammed Ali Elshikh | prismatechwork.com                 ║"
echo "  ║                                                  ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️         ║"
echo "  ║     Not intended for production use.             ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""

# ------------------------------------
# Step 0: Root check
# ------------------------------------

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║                                                      ║"
echo "  ║  ⚠️   DEMO / TESTING USE ONLY                        ║"
echo "  ║                                                      ║"
echo "  ║  This installer is intended for demo and testing.   ║"
echo "  ║  For a production-ready, hardened setup contact:    ║"
echo "  ║                                                      ║"
echo "  ║  👨‍💻  Mohammed Ali Elshikh                            ║"
echo "  ║  🌐  prismatechwork.com                              ║"
echo "  ║                                                      ║"
echo "  ║  Press ENTER to continue with demo install...       ║"
echo "  ║  Press Ctrl+C to cancel.                            ║"
echo "  ║                                                      ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
read -rp "" _DEMO_CONFIRM
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
# Step 4: Stop & Remove existing containers
# ------------------------------------
section "Step 4: Cleaning Up Existing Guacamole Containers"

EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E 'guacamole' || true)

if [ -n "$EXISTING" ]; then
    warn "Found existing Guacamole containers. Stopping and removing..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
    info "Containers removed."
else
    info "No existing Guacamole containers found."
fi

# Prune any dangling networks
docker network prune -f &>/dev/null || true

# ------------------------------------
# Step 5: Clean existing directory
# ------------------------------------
section "Step 5: Preparing Installation Directory"
GUAC_DIR="/root/docker/guacamole"

if [ -d "$GUAC_DIR" ]; then
    warn "Existing directory found at $GUAC_DIR. Removing..."
    rm -rf "$GUAC_DIR"
fi

mkdir -p "$GUAC_DIR"
cd "$GUAC_DIR" || error "Failed to navigate to $GUAC_DIR"
info "Directory ready: $GUAC_DIR"

# ------------------------------------
# Step 6: Generate docker-compose.yml
# ------------------------------------
section "Step 6: Generating docker-compose.yml"

cat > "$GUAC_DIR/docker-compose.yml" <<EOF
services:
  guacamole:
    image: jwetzell/guacamole
    container_name: guacamole
    restart: unless-stopped
    volumes:
      - ./postgres:/config
    ports:
      - 8085:8080

volumes:
  postgres:
    driver: local
EOF

info "docker-compose.yml created at $GUAC_DIR/docker-compose.yml"

# ------------------------------------
# Step 7: Start containers
# ------------------------------------
section "Step 7: Starting Guacamole Container"

if docker compose version &> /dev/null; then
    docker compose up -d
elif command -v docker-compose &> /dev/null; then
    docker-compose up -d
else
    error "Docker Compose not found. Cannot start containers."
fi

# ------------------------------------
# Step 8: Verify container is running
# ------------------------------------
section "Step 8: Verifying Container"
sleep 5

RUNNING=$(docker ps --format '{{.Names}}' | grep -E 'guacamole' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started correctly. Check logs:"
    echo "  docker logs guacamole"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for Guacamole to be ready on port 8085..."
HEALTH_OK=0
for i in $(seq 1 12); do
    if curl -sf --max-time 3 http://127.0.0.1:8085 &>/dev/null; then
        info "Port 8085 is responding — Guacamole is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 8085 2>/dev/null; then
        warn "Port 8085 is open but HTTP did not respond. Service may still be starting."
        warn "Check logs: docker logs guacamole"
    else
        warn "Port 8085 is NOT responding after 60s."
        warn "Check logs: docker logs guacamole"
        docker logs --tail 20 guacamole 2>&1 || true
    fi
fi

# ------------------------------------
# Done
# ------------------------------------
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
ADMIN_URL="http://$SERVER_IP:8085"

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Guacamole in your browser:               ║"
echo "  ║                                                      ║"
echo "  ║      👉  $ADMIN_URL"
echo "  ║                                                      ║"
echo "  ║  🔑 Default Login Credentials:                      ║"
echo "  ║     Username : guacadmin                            ║"
echo "  ║     Password : guacadmin                            ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  Change credentials immediately after login!    ║"
echo "  ║                                                      ║"
echo "  ║  Directory : $GUAC_DIR"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh | prismatechwork.com                   ║"
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
