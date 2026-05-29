#!/bin/bash
#
# ============================================================
#   SoftEther VPN Server Auto-Installer
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
echo "  ║       SoftEther VPN Server Auto-Installer        ║"
echo "  ║       Made by: Mohammed Ali Elshikh              ║"
echo "  ║       prismatechwork.com                         ║"
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
if ! command -v docker &>/dev/null; then
    warn "Docker not found. Installing..."
    apt update -y && apt install -y docker.io
    systemctl enable --now docker
    info "Docker installed."
else
    info "Docker: $(docker --version)"
fi

section "Step 3: Checking Docker Compose V2"
if ! docker compose version &>/dev/null; then
    warn "Docker Compose V2 not found. Installing..."
    apt update -y && apt install -y docker-compose-v2 || apt install -y docker-compose
    info "Docker Compose installed."
else
    info "Docker Compose: $(docker compose version)"
fi

section "Step 4: Cleaning Up Existing Containers"
for cname in softether-vpn softether-setup; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    if [ -n "$EXISTING" ]; then
        warn "Removing existing container: $cname"
        docker rm -f "$cname" 2>/dev/null || true
    fi
done
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
SE_DIR="/root/docker/softether"
if [ -d "$SE_DIR" ]; then
    warn "Removing old directory $SE_DIR..."
    rm -rf "$SE_DIR"
fi
mkdir -p "$SE_DIR"
cd "$SE_DIR" || error "Cannot navigate to $SE_DIR"
info "Directory ready: $SE_DIR"

section "Step 6: Configuration"
read -rp "  Pre-shared key for L2TP/IPsec [default: vpnpsk]: " PSK
PSK="${PSK:-vpnpsk}"
read -rp "  VPN username [default: vpnuser]: " VPN_USER
VPN_USER="${VPN_USER:-vpnuser}"
read -rsp "  VPN password [default: vpnpass]: " VPN_PASS
echo
VPN_PASS="${VPN_PASS:-vpnpass}"
read -rsp "  Management password [default: Admin1234!]: " MGMT_PASS
echo
MGMT_PASS="${MGMT_PASS:-Admin1234!}"
info "Configuration set."

section "Step 7: Creating docker-compose.yml"
cat > "$SE_DIR/docker-compose.yml" <<EOF
services:
  softether:
    image: siomiz/softethervpn:latest
    container_name: softether-vpn
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
    environment:
      - PSK=${PSK}
      - USERS=${VPN_USER}:${VPN_PASS}
      - SPW=${MGMT_PASS}
      - HPW=${MGMT_PASS}
    ports:
      - "500:500/udp"
      - "4500:4500/udp"
      - "1701:1701/tcp"
      - "1194:1194/udp"
      - "443:443/tcp"
      - "5555:5555/tcp"
    volumes:
      - ./vpndata:/usr/vpnserver
    sysctls:
      - net.ipv4.ip_forward=1
EOF
info "docker-compose.yml created."

section "Step 8: Pre-populating VPN Data Directory"
# Docker 29 + Ubuntu 24.04 overlayfs bug: fails to initialise anonymous
# volumes for images that declare VOLUME /usr/vpnserver. A pre-populated
# bind mount at that exact path bypasses the broken code path entirely.
info "Pulling image..."
docker pull siomiz/softethervpn:latest
mkdir -p "$SE_DIR/vpndata"

if docker create --name softether-setup siomiz/softethervpn:latest >/dev/null 2>&1; then
    info "Extracting files via docker create..."
    docker cp softether-setup:/usr/vpnserver/. "$SE_DIR/vpndata/"
    docker rm softether-setup >/dev/null
    info "VPN data directory ready."
else
    warn "docker create hit overlayfs bug — extracting directly from image layers..."
    docker rm -f softether-setup 2>/dev/null || true
    SE_TMP="$(mktemp -d)"
    docker save siomiz/softethervpn:latest | tar x -C "$SE_TMP"
    mkdir -p "$SE_TMP/merged"
    # Legacy Docker save format: <hash>/layer.tar
    find "$SE_TMP" -name "layer.tar" | sort | while IFS= read -r lf; do
        tar xf "$lf" -C "$SE_TMP/merged" --overwrite 2>/dev/null || true
    done
    # OCI format: blobs/sha256/* (detect tar archives by content)
    if [ -f "$SE_TMP/index.json" ]; then
        for bf in "$SE_TMP/blobs/sha256/"*; do
            [ -f "$bf" ] || continue
            tar tf "$bf" 2>/dev/null | grep -q "^usr/\|^\./usr/" && \
                tar xf "$bf" -C "$SE_TMP/merged" --overwrite 2>/dev/null || true
        done
    fi
    [ -d "$SE_TMP/merged/usr/vpnserver" ] || { rm -rf "$SE_TMP"; error "Could not extract SoftEther files from image."; }
    cp -a "$SE_TMP/merged/usr/vpnserver/." "$SE_DIR/vpndata/"
    chmod +x "$SE_DIR/vpndata"/* 2>/dev/null || true
    rm -rf "$SE_TMP"
    info "VPN data directory ready (extracted from layers)."
fi

section "Step 9: Starting SoftEther VPN"
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    if docker compose version &>/dev/null; then
        docker compose up -d && break
    else
        docker-compose up -d && break
    fi
    warn "Attempt $attempt/$MAX_RETRIES failed."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed after $MAX_RETRIES attempts. Run manually: cd $SE_DIR && docker compose up -d"
done

section "Step 10: Verifying Container"
sleep 5
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^softether-vpn$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs softether-vpn"
else
    info "Container running: $RUNNING"
fi

section "Step 11: Health Check"
info "Waiting for SoftEther management port 5555 to open..."
HEALTH_OK=0
for i in $(seq 1 12); do
    if nc -z 127.0.0.1 5555 2>/dev/null; then
        info "Port 5555 is open — SoftEther is ready. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    warn "Port 5555 is not responding after 60s."
    docker logs --tail 20 softether-vpn 2>&1 || true
fi

section "Step 12: Opening Firewall Ports"
if command -v ufw &>/dev/null; then
    ufw allow 500/udp   comment "SoftEther L2TP/IPsec IKE"   2>/dev/null || true
    ufw allow 4500/udp  comment "SoftEther L2TP/IPsec NAT-T"  2>/dev/null || true
    ufw allow 1701/tcp  comment "SoftEther L2TP"              2>/dev/null || true
    ufw allow 1194/udp  comment "SoftEther OpenVPN"           2>/dev/null || true
    ufw allow 443/tcp   comment "SoftEther SSTP"              2>/dev/null || true
    ufw allow 5555/tcp  comment "SoftEther Management"        2>/dev/null || true
    info "UFW rules applied."
else
    warn "UFW not found — open ports manually: UDP 500,4500,1194 | TCP 443,1701,5555"
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🔐  L2TP/IPsec (iOS / Android / Windows):         ║"
echo "  ║      Server  : $SERVER_IP"
echo "  ║      PSK     : $PSK"
echo "  ║      User    : $VPN_USER"
echo "  ║      Pass    : $VPN_PASS"
echo "  ║                                                      ║"
echo "  ║  🖥️  Management (SoftEther VPN Manager app):        ║"
echo "  ║      Host    : $SERVER_IP"
echo "  ║      Port    : 5555"
echo "  ║      Pass    : $MGMT_PASS"
echo "  ║                                                      ║"
echo "  ║  ⚠️  Port 5555 is NOT a web page.                   ║"
echo "  ║     Use the SoftEther VPN Server Manager app:       ║"
echo "  ║     https://www.softether-download.com              ║"
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
