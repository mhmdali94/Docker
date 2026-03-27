#!/bin/bash
#
# ============================================================
#   Mailu Email Server Auto-Installer
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
echo "  ║       Mailu Email Server Auto-Installer          ║"
echo "  ║       Made by: Mohammed Ali Elshikh | prismatechwork.com                ║"
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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E 'mailu' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing Mailu containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
MAILU_DIR="/root/docker/mailu"
if [ -d "$MAILU_DIR" ]; then
    warn "Removing old directory $MAILU_DIR..."
    rm -rf "$MAILU_DIR"
fi
mkdir -p "$MAILU_DIR"
cd "$MAILU_DIR" || error "Cannot navigate to $MAILU_DIR"
info "Directory ready: $MAILU_DIR"

section "Step 6: Detecting Server IP"
WAN_IP=$(curl -4 -s --max-time 5 https://ifconfig.me || curl -4 -s --max-time 5 https://api4.ipify.org || hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
info "Detected IP: $WAN_IP"

section "Step 7: Generating Credentials & Config"
SECRET_KEY=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)
ADMIN_PASS=$(tr -dc 'A-Za-z0-9!@#$%' < /dev/urandom | head -c 20)
MAIL_DOMAIN="example.com"

cat > "$MAILU_DIR/mailu.env" <<EOF
# Mailu configuration
SECRET_KEY=$SECRET_KEY
DOMAIN=$MAIL_DOMAIN
HOSTNAMES=mail.$MAIL_DOMAIN
POSTMASTER=admin
TLS_FLAVOR=notls
AUTH_RATELIMIT_IP=60/hour
AUTH_RATELIMIT_USER=100/day
INITIAL_ADMIN_ACCOUNT=admin
INITIAL_ADMIN_DOMAIN=$MAIL_DOMAIN
INITIAL_ADMIN_PW=$ADMIN_PASS
SUBNET=192.168.203.0/24
PASSWORD_SCHEME=PBKDF2
WEBROOT_REDIRECT=/roundcube
WEBMAIL=roundcube
ADMIN=true
EOF
info "mailu.env created."

cat > "$MAILU_DIR/docker-compose.yml" <<EOF
services:
  mailu-front:
    image: ghcr.io/mailu/nginx:2.0
    container_name: mailu-front
    restart: unless-stopped
    env_file: mailu.env
    ports:
      - "80:80"
      - "443:443"
      - "25:25"
      - "465:465"
      - "587:587"
      - "110:110"
      - "995:995"
      - "143:143"
      - "993:993"
    volumes:
      - ./certs:/certs
      - ./overrides/nginx:/overrides:ro
    networks:
      - mailu-net

  mailu-admin:
    image: ghcr.io/mailu/admin:2.0
    container_name: mailu-admin
    restart: unless-stopped
    env_file: mailu.env
    volumes:
      - ./data:/data
      - ./dkim:/dkim
    depends_on:
      - mailu-redis
    networks:
      - mailu-net

  mailu-smtp:
    image: ghcr.io/mailu/postfix:2.0
    container_name: mailu-smtp
    restart: unless-stopped
    env_file: mailu.env
    volumes:
      - ./mailqueue:/queue
      - ./overrides/postfix:/overrides:ro
    networks:
      - mailu-net

  mailu-imap:
    image: ghcr.io/mailu/dovecot:2.0
    container_name: mailu-imap
    restart: unless-stopped
    env_file: mailu.env
    volumes:
      - ./mail:/mail
      - ./overrides/dovecot:/overrides:ro
    networks:
      - mailu-net

  mailu-antispam:
    image: ghcr.io/mailu/rspamd:2.0
    container_name: mailu-antispam
    restart: unless-stopped
    env_file: mailu.env
    volumes:
      - ./filter:/var/lib/rspamd
      - ./overrides/rspamd:/overrides:ro
    networks:
      - mailu-net

  mailu-webmail:
    image: ghcr.io/mailu/roundcube:2.0
    container_name: mailu-webmail
    restart: unless-stopped
    env_file: mailu.env
    volumes:
      - ./webmail:/data
    networks:
      - mailu-net

  mailu-redis:
    image: redis:alpine
    container_name: mailu-redis
    restart: unless-stopped
    volumes:
      - ./redis:/data
    networks:
      - mailu-net

networks:
  mailu-net:
    driver: bridge
    ipam:
      config:
        - subnet: 192.168.203.0/24
EOF
info "docker-compose.yml created."

section "Step 8: Starting Mailu"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 9: Verifying Containers"
sleep 10
RUNNING=$(docker ps --format '{{.Names}}' | grep -E 'mailu' || true)
if [ -z "$RUNNING" ]; then
    warn "Containers may not have started. Check: docker compose logs"
else
    info "Containers running: $(echo "$RUNNING" | wc -l) mailu services"
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Mailu Admin UI in your browser:          ║"
echo "  ║      👉  http://$SERVER_IP/admin"
echo "  ║                                                      ║"
echo "  ║  📬  Webmail (Roundcube):                          ║"
echo "  ║      👉  http://$SERVER_IP/roundcube"
echo "  ║                                                      ║"
echo "  ║  🔑  Default Login Credentials:                     ║"
echo "  ║      Username : admin@$MAIL_DOMAIN"
echo "  ║      Password : $ADMIN_PASS"
echo "  ║                                                      ║"
echo "  ║  ⚠️  Change the admin password immediately!         ║"
echo "  ║                                                      ║"
echo "  ║  📧  Services included:                             ║"
echo "  ║      • Postfix  (SMTP)   → port 25, 587, 465       ║"
echo "  ║      • Dovecot (IMAP)   → port 143, 993            ║"
echo "  ║      • Roundcube (Webmail)                         ║"
echo "  ║      • Rspamd  (Antispam)                          ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  A real domain + DNS records are required       ║"
echo "  ║      for production email delivery.                 ║"
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
