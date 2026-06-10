#!/bin/bash
#
# ============================================================
#   Outline VPN Server Auto-Installer
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
echo "  ║       Outline VPN Server Auto-Installer          ║"
echo "  ║       Made by: Mohammed Ali Elshikh             ║"
echo "  ║       prismatechwork.com                        ║"
echo "  ║                                                  ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️         ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║  ⚠️   DEMO / TESTING USE ONLY                        ║"
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

section "Step 2: Checking Docker"
if ! command -v docker &> /dev/null; then
    warn "Docker not found. Installing..."
    apt update -y && apt install -y docker.io
    systemctl enable --now docker
    info "Docker installed."
else
    info "Docker: $(docker --version)"
fi

section "Step 3: Preparing Directory & Certificates"
OL_DIR="/root/docker/outline"
if [ -d "$OL_DIR" ]; then
    warn "Removing old directory $OL_DIR..."
    rm -rf "$OL_DIR"
fi
mkdir -p "$OL_DIR/data"
cd "$OL_DIR" || error "Cannot navigate to $OL_DIR"
info "Directory ready: $OL_DIR"

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
API_PREFIX=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 16)
MGMT_PORT=8081
ACCESS_PORT=8080

# Generate self-signed certificate
info "Generating self-signed TLS certificate..."
apt install -y openssl &>/dev/null
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$OL_DIR/data/shadowbox-selfsigned.key" \
    -out "$OL_DIR/data/shadowbox-selfsigned.crt" \
    -subj "/CN=$SERVER_IP" &>/dev/null
CERT_SHA256=$(openssl x509 -in "$OL_DIR/data/shadowbox-selfsigned.crt" -noout -fingerprint -sha256 | cut -d= -f2 | tr -d ':')
info "Certificate generated. SHA256: $CERT_SHA256"

cat > "$OL_DIR/data/shadowbox_config.json" <<EOF
{"rollouts":[{"id":"single-port","enabled":false}],"portForNewAccessKeys":$ACCESS_PORT}
EOF

section "Step 4: Cleaning Up Existing Containers"
if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -qE '^outline-shadowbox$'; then
    docker rm -f outline-shadowbox 2>/dev/null || true
fi

section "Step 5: Starting Outline Shadowbox"
docker run -d \
    --name outline-shadowbox \
    --restart unless-stopped \
    --net host \
    --label 'com.centurylinklabs.watchtower.enable=true' \
    --label 'com.centurylinklabs.watchtower.stop-signal=SIGHUP' \
    -v "$OL_DIR/data:/root/shadowbox/persisted-state" \
    -e "SB_STATE_DIR=/root/shadowbox/persisted-state" \
    -e "SB_API_PORT=$MGMT_PORT" \
    -e "SB_API_PREFIX=$API_PREFIX" \
    -e "SB_CERTIFICATE_FILE=/root/shadowbox/persisted-state/shadowbox-selfsigned.crt" \
    -e "SB_PRIVATE_KEY_FILE=/root/shadowbox/persisted-state/shadowbox-selfsigned.key" \
    -e "SB_METRICS_URL=" \
    quay.io/outline/shadowbox:stable

section "Step 6: Verifying Container"
sleep 8
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^outline-shadowbox$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs outline-shadowbox"
else
    info "Container running: $RUNNING"
fi

section "Step 7: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    ufw allow "$MGMT_PORT"/tcp
    ufw allow "$ACCESS_PORT"/tcp
    ufw allow "$ACCESS_PORT"/udp
    info "UFW: ports $MGMT_PORT/tcp and $ACCESS_PORT/tcp+udp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

API_URL="https://$SERVER_IP:$MGMT_PORT/$API_PREFIX"
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Outline Manager API URL:                       ║"
echo "  ║      $API_URL"
echo "  ║                                                      ║"
echo "  ║  🔒  Certificate fingerprint (SHA-256):             ║"
echo "  ║      $CERT_SHA256"
echo "  ║                                                      ║"
echo "  ║  📋  Add to Outline Manager app:                   ║"
echo "  ║      {\"apiUrl\":\"$API_URL\","
echo "  ║       \"certSha256\":\"$CERT_SHA256\"}"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║  🚀  Need production setup?                         ║"
echo "  ║      👨‍💻  Mohammed Ali Elshikh | prismatechwork.com  ║"
echo "  ║  ☕  USDT TRC-20: TCSZTkXvhibdrFre5sdTsFLRQ6d6yQkd2i ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
