#!/bin/bash
# ============================================================
#   Jitsi Meet Auto-Installer
#   Made by: Mohammed Ali Elshikh | prismatechwork.com
#   ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️
# ============================================================
set -e
G="\e[32m"; Y="\e[33m"; R="\e[31m"; C="\e[36m"; B="\e[1m"; RST="\e[0m"
info()    { echo -e "${G}[INFO]${RST} $*"; }
warn()    { echo -e "${Y}[WARN]${RST} $*"; }
error()   { echo -e "${R}[ERROR]${RST} $*"; exit 1; }
section() { echo -e "\n${C}${B}══════════════════════ $* ══════════════════════${RST}"; }

clear
echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║     Jitsi Meet Auto-Installer                   ║"
echo "  ║     Made by: Mohammed Ali Elshikh              ║"
echo "  ║     prismatechwork.com                         ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️        ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""
echo "  Press ENTER to continue ... Ctrl+C to cancel."
read -rp "" _

section "Step 0: Checking Privileges"
[ "$EUID" -ne 0 ] && error "Please run as root: sudo bash $0"
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

section "Step 4: Server Address"
echo ""
warn "Jitsi Meet requires a public IP or domain to work correctly."
warn "It will NOT work properly with only a local/LAN address for remote participants."
echo ""
SERVER_IP_DEFAULT=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
read -rp "  Enter your server's public IP or domain [$SERVER_IP_DEFAULT]: " PUBLIC_ADDR
PUBLIC_ADDR="${PUBLIC_ADDR:-$SERVER_IP_DEFAULT}"
info "Using: $PUBLIC_ADDR"

section "Step 5: Generating Passwords"
JICOFO_PASS=$(openssl rand -hex 16)
JVB_PASS=$(openssl rand -hex 16)
info "Internal passwords generated."

section "Step 6: Cleaning Up Existing Containers"
for cname in jitsi-web jitsi-prosody jitsi-jicofo jitsi-jvb; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    [ -n "$EXISTING" ] && warn "Removing $cname..." && docker rm -f "$cname" 2>/dev/null || true
done

section "Step 7: Preparing Directory"
APP_DIR="/root/docker/jitsi"
mkdir -p "$APP_DIR"/{web,transcripts,prosody/config,prosody/prosody-plugins-custom}
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 8: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  web:
    image: jitsi/web:stable-9457
    container_name: jitsi-web
    restart: unless-stopped
    ports:
      - "8443:443"
      - "8080:80"
    environment:
      PUBLIC_URL: https://${PUBLIC_ADDR}:8443
      ENABLE_LETSENCRYPT: "0"
      XMPP_DOMAIN: meet.jitsi
      XMPP_AUTH_DOMAIN: auth.meet.jitsi
      XMPP_MUC_DOMAIN: muc.meet.jitsi
      XMPP_GUEST_DOMAIN: guest.meet.jitsi
      TZ: UTC
    volumes:
      - ./web:/config
      - ./transcripts:/usr/share/jitsi-meet/transcripts
    depends_on:
      - prosody

  prosody:
    image: jitsi/prosody:stable-9457
    container_name: jitsi-prosody
    restart: unless-stopped
    expose:
      - "5222"
      - "5347"
      - "5280"
    environment:
      XMPP_DOMAIN: meet.jitsi
      XMPP_AUTH_DOMAIN: auth.meet.jitsi
      XMPP_MUC_DOMAIN: muc.meet.jitsi
      XMPP_INTERNAL_MUC_DOMAIN: internal-muc.meet.jitsi
      XMPP_GUEST_DOMAIN: guest.meet.jitsi
      JICOFO_AUTH_USER: focus
      JICOFO_AUTH_PASSWORD: ${JICOFO_PASS}
      JVB_AUTH_USER: jvb
      JVB_AUTH_PASSWORD: ${JVB_PASS}
      TZ: UTC
    volumes:
      - ./prosody/config:/config
      - ./prosody/prosody-plugins-custom:/prosody-plugins-custom

  jicofo:
    image: jitsi/jicofo:stable-9457
    container_name: jitsi-jicofo
    restart: unless-stopped
    environment:
      XMPP_DOMAIN: meet.jitsi
      XMPP_AUTH_DOMAIN: auth.meet.jitsi
      XMPP_INTERNAL_MUC_DOMAIN: internal-muc.meet.jitsi
      XMPP_SERVER: prosody
      JICOFO_AUTH_USER: focus
      JICOFO_AUTH_PASSWORD: ${JICOFO_PASS}
      JVB_BREWERY_MUC: jvbbrewery
      TZ: UTC
    depends_on:
      - prosody

  jvb:
    image: jitsi/jvb:stable-9457
    container_name: jitsi-jvb
    restart: unless-stopped
    ports:
      - "10000:10000/udp"
      - "4443:4443"
    environment:
      DOCKER_HOST_ADDRESS: ${PUBLIC_ADDR}
      XMPP_AUTH_DOMAIN: auth.meet.jitsi
      XMPP_INTERNAL_MUC_DOMAIN: internal-muc.meet.jitsi
      XMPP_SERVER: prosody
      JVB_AUTH_USER: jvb
      JVB_AUTH_PASSWORD: ${JVB_PASS}
      JVB_BREWERY_MUC: jvbbrewery
      JVB_PORT: 10000
      TZ: UTC
    depends_on:
      - prosody
EOF
info "docker-compose.yml created."

section "Step 9: Starting Jitsi Meet"
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start. Run: cd $APP_DIR && docker compose up -d"
else
    docker-compose up -d || error "Failed to start. Run: cd $APP_DIR && docker-compose up -d"
fi

section "Step 10: Health Check"
info "Waiting for Jitsi Meet to be ready..."
for i in $(seq 1 12); do
    if curl -sfk --max-time 3 http://127.0.0.1:8080 &>/dev/null; then
        info "Jitsi Meet is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done

section "Step 11: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 8443/tcp
    ufw allow 8080/tcp
    ufw allow 10000/udp
    ufw allow 4443/tcp
    info "UFW: ports 8443, 8080, 10000/udp, 4443 opened."
else
    warn "UFW not found — skipping."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  📹  Jitsi Meet:                                   ║"
echo "  ║      👉  http://${PUBLIC_ADDR}:8080"
echo "  ║                                                      ║"
echo "  ║  Anyone can create a room — just visit and start    ║"
echo "  ║  Add a room password in the meeting settings        ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║                                                      ║"
echo "  ║  ☕  Support This Script                             ║"
echo "  ║                                                      ║"
echo "  ║  If this script saved you time, consider sending a  ║"
echo "  ║  small tip in USDT. It keeps the content free and   ║"
echo "  ║  helps publish more guides.                         ║"
echo "  ║                                                      ║"
echo "  ║  USDT · TRC-20:                                     ║"
echo "  ║  TCSZTkXvhibdrFre5sdTsFLRQ6d6yQkd2i               ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  TRC-20 network only. Do not send on ERC-20.   ║"
echo "  ║      Funds sent on other networks cannot be         ║"
echo "  ║      recovered.                                     ║"
echo "  ║                                                      ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
