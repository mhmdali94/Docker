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
echo "  ║  🚀  Need production setup?                         ║"
echo "  ║      👨‍💻  Mohammed Ali Elshikh                      ║"
echo "  ║      🌐  prismatechwork.com                         ║"
echo "  ║                                                      ║"
echo "  ║  ☕  Support this script — USDT (TRC-20 only):     ║"
echo "  ║      TCSZTkXvhibdrFre5sdTsFLRQ6d6yQkd2i           ║"
echo "  ║                                                      ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""

# ============================================================
#   Pre-flight checks
# ============================================================

section "Checking requirements"

if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root. Try: sudo bash softether-ubuntu.sh"
fi

OS=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
if [[ "$OS" != "ubuntu" && "$OS" != "debian" ]]; then
    warn "This script is designed for Ubuntu/Debian. Detected: $OS — proceeding anyway."
fi

info "Running on: $(lsb_release -ds 2>/dev/null || echo "$OS")"

# ============================================================
#   Collect configuration
# ============================================================

section "Configuration"

read -rp "  Enter a pre-shared key (PSK) for L2TP/IPsec [default: vpnpsk]: " PSK
PSK="${PSK:-vpnpsk}"

read -rp "  Enter admin username for VPN hub [default: vpnuser]: " VPN_USER
VPN_USER="${VPN_USER:-vpnuser}"

read -rsp "  Enter password for VPN user [default: vpnpass]: " VPN_PASS
echo
VPN_PASS="${VPN_PASS:-vpnpass}"

read -rsp "  Enter SoftEther management password [default: Admin1234!]: " MGMT_PASS
echo
MGMT_PASS="${MGMT_PASS:-Admin1234!}"

INSTALL_DIR="/opt/softether"
info "Install directory: $INSTALL_DIR"

# ============================================================
#   Install Docker
# ============================================================

section "Installing Docker"

if command -v docker &>/dev/null; then
    info "Docker already installed: $(docker --version)"
else
    info "Installing Docker..."
    apt-get update -qq
    apt-get install -y -qq ca-certificates curl gnupg lsb-release

    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
        gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
        https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt-get update -qq
    apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-compose-plugin
    systemctl enable --now docker
    info "Docker installed successfully."
fi

if command -v docker compose &>/dev/null; then
    COMPOSE_CMD="docker compose"
elif command -v docker-compose &>/dev/null; then
    COMPOSE_CMD="docker-compose"
else
    info "Installing docker-compose standalone..."
    curl -fsSL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    COMPOSE_CMD="docker-compose"
fi

info "Compose command: $COMPOSE_CMD"

# ============================================================
#   Create directory and docker-compose.yml
# ============================================================

section "Setting up SoftEther"

mkdir -p "$INSTALL_DIR"

cat > "$INSTALL_DIR/docker-compose.yml" <<EOF
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

info "docker-compose.yml created at $INSTALL_DIR/docker-compose.yml"

# ============================================================
#   Pull image and pre-populate bind-mount directory
#
#   Docker 29 + Ubuntu 24.04 overlayfs fails to initialise
#   named/anonymous volumes for this image (the VOLUME
#   declaration in the image triggers a copy that hits the
#   vpnserver binary and errors "is not directory").
#   Using a pre-populated bind mount at /usr/vpnserver bypasses
#   that code path entirely.
# ============================================================

section "Starting SoftEther VPN container"

cd "$INSTALL_DIR"

# Always clean up any previous failed attempt so re-running is safe
info "Cleaning up any previous state..."
$COMPOSE_CMD down -v 2>/dev/null || true
docker rm -f softether-vpn softether-setup 2>/dev/null || true

info "Pulling image..."
docker pull siomiz/softethervpn:latest

populate_vpndata() {
    mkdir -p "$INSTALL_DIR/vpndata"

    # Primary path: docker create + cp (fast, no disk overhead)
    # Suppress errors — on Docker 29 + Ubuntu 24.04 this can hit
    # the same overlayfs bug as compose up.
    if docker create --name softether-setup siomiz/softethervpn:latest >/dev/null 2>&1; then
        info "Extracting files via docker create..."
        docker cp softether-setup:/usr/vpnserver/. "$INSTALL_DIR/vpndata/"
        docker rm softether-setup >/dev/null
        return 0
    fi

    # Fallback: extract from saved image layers without ever creating a container.
    warn "docker create hit the overlayfs bug — falling back to layer extraction..."
    docker rm -f softether-setup 2>/dev/null || true

    local SE_TMP
    SE_TMP="$(mktemp -d)"
    info "Saving image and extracting layers (may take a moment)..."
    docker save siomiz/softethervpn:latest | tar x -C "$SE_TMP"
    mkdir -p "$SE_TMP/merged"

    # Legacy Docker save format: blobs live as <hash>/layer.tar
    find "$SE_TMP" -name "layer.tar" | sort | while IFS= read -r lf; do
        tar xf "$lf" -C "$SE_TMP/merged" --overwrite 2>/dev/null || true
    done

    # OCI format: blobs/sha256/* — detect by checking if it's a tar archive
    if [ -f "$SE_TMP/index.json" ]; then
        for bf in "$SE_TMP/blobs/sha256/"*; do
            [ -f "$bf" ] || continue
            tar tf "$bf" 2>/dev/null | grep -q "^usr/\|^\./usr/" && \
                tar xf "$bf" -C "$SE_TMP/merged" --overwrite 2>/dev/null || true
        done
    fi

    if [ ! -d "$SE_TMP/merged/usr/vpnserver" ]; then
        rm -rf "$SE_TMP"
        error "Could not extract SoftEther files from image layers. Check that the image supports $(uname -m)."
    fi

    cp -a "$SE_TMP/merged/usr/vpnserver/." "$INSTALL_DIR/vpndata/"
    chmod +x "$INSTALL_DIR/vpndata"/* 2>/dev/null || true
    rm -rf "$SE_TMP"
}

if [ ! -d "$INSTALL_DIR/vpndata" ] || [ -z "$(ls -A "$INSTALL_DIR/vpndata" 2>/dev/null)" ]; then
    info "Pre-populating VPN data directory from image..."
    populate_vpndata
    info "VPN data directory ready."
fi

$COMPOSE_CMD up -d
info "Container started."

# ============================================================
#   Configure firewall (UFW)
# ============================================================

section "Configuring firewall"

if command -v ufw &>/dev/null; then
    ufw allow 500/udp   comment "SoftEther L2TP/IPsec IKE"  2>/dev/null || true
    ufw allow 4500/udp  comment "SoftEther L2TP/IPsec NAT-T" 2>/dev/null || true
    ufw allow 1701/tcp  comment "SoftEther L2TP"             2>/dev/null || true
    ufw allow 1194/udp  comment "SoftEther OpenVPN"          2>/dev/null || true
    ufw allow 443/tcp   comment "SoftEther SSTP"             2>/dev/null || true
    ufw allow 5555/tcp  comment "SoftEther Management"       2>/dev/null || true
    info "UFW rules applied."
else
    warn "UFW not found — open these ports manually in your firewall/security group:"
    warn "  UDP 500, 4500, 1194  |  TCP 443, 1701, 5555"
fi

# ============================================================
#   Done
# ============================================================

section "Installation Complete"

SERVER_IP=$(curl -s https://api.ipify.org 2>/dev/null || hostname -I | awk '{print $1}')

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              SoftEther VPN is Running!              ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  Server IP   : $SERVER_IP"
echo "  ║  PSK         : $PSK"
echo "  ║  VPN User    : $VPN_USER"
echo "  ║  VPN Pass    : $VPN_PASS"
echo "  ║  Mgmt Pass   : $MGMT_PASS"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  Management  : $SERVER_IP:5555 (SoftEther Manager)  ║"
echo "  ║  L2TP/IPsec  : native VPN on iOS/Android/Windows    ║"
echo "  ║  OpenVPN     : $SERVER_IP:1194                      ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
echo "  Manage the container:"
echo "    cd $INSTALL_DIR"
echo "    $COMPOSE_CMD logs -f       # view logs"
echo "    $COMPOSE_CMD restart       # restart"
echo "    $COMPOSE_CMD down          # stop"
echo ""
echo "  Download SoftEther VPN Server Manager:"
echo "    https://www.softether-download.com"
echo "    Connect to: $SERVER_IP:5555"
echo ""
