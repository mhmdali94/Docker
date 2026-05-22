#!/bin/bash
#
# ============================================================
#   Watchtower Auto-Installer
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
echo "  ║         Watchtower Auto-Installer                ║"
echo "  ║         Made by: Mohammed Ali Elshikh           ║"
echo "  ║         prismatechwork.com                      ║"
echo "  ║                                                  ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️         ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""

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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^watchtower$' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing container: watchtower"
    docker rm -f watchtower 2>/dev/null || true
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
WT_DIR="/root/docker/watchtower"
if [ -d "$WT_DIR" ]; then
    warn "Removing old directory $WT_DIR..."
    rm -rf "$WT_DIR"
fi
mkdir -p "$WT_DIR"
cd "$WT_DIR" || error "Cannot navigate to $WT_DIR"
info "Directory ready: $WT_DIR"

section "Step 6: Writing docker-compose.yml"
cat > "$WT_DIR/docker-compose.yml" <<'EOF'
services:
  watchtower:
    image: containrrr/watchtower:latest
    container_name: watchtower
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      WATCHTOWER_CLEANUP: "true"
      WATCHTOWER_SCHEDULE: "0 0 4 * * *"
      WATCHTOWER_NOTIFICATIONS_LEVEL: info
      WATCHTOWER_INCLUDE_STOPPED: "false"
      WATCHTOWER_REVIVE_STOPPED: "false"
EOF
info "docker-compose.yml created."
info "Schedule: daily at 04:00 UTC. Old images will be removed after update."

section "Step 7: Starting Watchtower"
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
sleep 5
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^watchtower$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs watchtower"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Daemon Check"
info "Watchtower runs silently as a daemon — no web UI."
info "Check logs with: docker logs watchtower"
info "It will check for updates at 04:00 UTC daily."

section "Step 10: No Firewall Rules Needed"
info "Watchtower makes only outbound connections — no ports to open."

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🔄  Watchtower is running as a background daemon.  ║"
echo "  ║                                                      ║"
echo "  ║  🕐  Update schedule: daily at 04:00 UTC            ║"
echo "  ║  🗑️  Old images: removed automatically              ║"
echo "  ║                                                      ║"
echo "  ║  📋  Check logs: docker logs watchtower             ║"
echo "  ║                                                      ║"
echo "  ║  🏷️  Exclude container from updates:                ║"
echo "  ║      Label: com.centurylinklabs.watchtower.enable=false"
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
