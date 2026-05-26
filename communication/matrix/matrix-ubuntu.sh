#!/bin/bash
#
# ============================================================
#   Matrix Synapse + Element Web Auto-Installer
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
echo "  ║   Matrix Synapse + Element Web Auto-Installer    ║"
echo "  ║   Made by: Mohammed Ali Elshikh                 ║"
echo "  ║   prismatechwork.com                            ║"
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
for cname in synapse element-web; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    if [ -n "$EXISTING" ]; then
        warn "Removing existing container: $cname"
        docker rm -f "$cname" 2>/dev/null || true
    fi
done
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory & Generating Synapse Config"
MATRIX_DIR="/root/docker/matrix"
if [ -d "$MATRIX_DIR" ]; then
    warn "Removing old directory $MATRIX_DIR..."
    rm -rf "$MATRIX_DIR"
fi
mkdir -p "$MATRIX_DIR/synapse"
cd "$MATRIX_DIR" || error "Cannot navigate to $MATRIX_DIR"
info "Directory ready: $MATRIX_DIR"

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)

info "Generating Synapse configuration..."
docker run --rm \
    -v "$MATRIX_DIR/synapse:/data" \
    -e SYNAPSE_SERVER_NAME="$SERVER_IP" \
    -e SYNAPSE_REPORT_STATS=no \
    matrixdotorg/synapse:latest generate
info "Synapse config generated."

# Enable open registration for demo
sed -i 's/#enable_registration: false/enable_registration: true/' "$MATRIX_DIR/synapse/homeserver.yaml" 2>/dev/null || true
sed -i 's/enable_registration: false/enable_registration: true/' "$MATRIX_DIR/synapse/homeserver.yaml" 2>/dev/null || true
echo "enable_registration_without_verification: true" >> "$MATRIX_DIR/synapse/homeserver.yaml"
info "Open registration enabled in homeserver.yaml."

section "Step 6: Writing Element Config & docker-compose.yml"
cat > "$MATRIX_DIR/element-config.json" <<EOF
{
  "default_server_config": {
    "m.homeserver": {
      "base_url": "http://$SERVER_IP:8008",
      "server_name": "$SERVER_IP"
    }
  },
  "disable_custom_urls": false,
  "disable_guests": false,
  "disable_login_language_selector": false,
  "disable_3pid_login": false,
  "brand": "Element",
  "integrations_ui_url": "",
  "integrations_rest_url": "",
  "bug_report_endpoint_url": "",
  "roomDirectory": {
    "servers": ["$SERVER_IP"]
  }
}
EOF

cat > "$MATRIX_DIR/docker-compose.yml" <<'EOF'
services:
  synapse:
    image: matrixdotorg/synapse:latest
    container_name: synapse
    restart: unless-stopped
    ports:
      - "8008:8008"
    volumes:
      - ./synapse:/data

  element-web:
    image: vectorim/element-web:latest
    container_name: element-web
    restart: unless-stopped
    ports:
      - "8009:80"
    volumes:
      - ./element-config.json:/app/config.json:ro
    depends_on:
      - synapse
EOF
info "docker-compose.yml created."

section "Step 7: Starting Matrix Synapse + Element Web"
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

section "Step 8: Verifying Containers"
sleep 8
for cname in synapse element-web; do
    RUNNING=$(docker ps --format '{{.Names}}' | grep -E "^${cname}$" || true)
    if [ -z "$RUNNING" ]; then
        warn "Container '$cname' may not have started. Check: docker logs $cname"
    else
        info "Container running: $cname"
    fi
done

section "Step 9: Health Check"
info "Waiting for Synapse to be ready on port 8008..."
HEALTH_OK=0
for i in $(seq 1 12); do
    if curl -sf --max-time 3 http://127.0.0.1:8008/health &>/dev/null; then
        info "Port 8008 is responding — Synapse is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    warn "Synapse may still be starting. Check: docker logs synapse"
fi

section "Step 10: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    ufw allow 8008/tcp
    ufw allow 8009/tcp
    info "UFW: ports 8008 and 8009/tcp opened."
else
    warn "UFW not found — skipping firewall rules."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Element Web (chat client):                   ║"
echo "  ║      👉  http://$SERVER_IP:8009"
echo "  ║                                                      ║"
echo "  ║  📡  Synapse Matrix server:                        ║"
echo "  ║      http://$SERVER_IP:8008"
echo "  ║                                                      ║"
echo "  ║  🔑  Register your account via Element Web.        ║"
echo "  ║      Homeserver URL: http://$SERVER_IP:8008"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║                                                      ║"
echo "  ║  🚀  Need production setup?                         ║"
echo "  ║      👨‍💻  Mohammed Ali Elshikh                      ║"
echo "  ║      🌐  prismatechwork.com                         ║"
echo "  ║                                                      ║"
echo "  ║  ☕  Support this script — USDT (TRC-20 only):     ║"
echo "  ║      TCSZTkXvhibdrFre5sdTsFLRQ6d6yQkd2i           ║"
echo "  ║                                                      ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
