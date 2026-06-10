#!/bin/bash
#
# ============================================================
#   Mailu Auto-Installer
#   Made by: Mohammed Ali Elshikh | prismatechwork.com
#
#   ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️
#   This script is NOT intended for production use.
#
#   NOTE: Mailu requires a valid domain and DNS records.
#   Ports 25, 80, 443, 587, 993 must be open.
# ============================================================

set -e

info()    { echo -e "\e[32m[INFO]\e[0m $*"; }
warn()    { echo -e "\e[33m[WARN]\e[0m $*"; }
error()   { echo -e "\e[31m[ERROR]\e[0m $*"; exit 1; }
section() { echo -e "\n\e[36m========== $* ==========\e[0m"; }

clear
echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║       Mailu Auto-Installer                       ║"
echo "  ║       Made by: Mohammed Ali Elshikh             ║"
echo "  ║       prismatechwork.com                        ║"
echo "  ║                                                  ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️         ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║  ⚠️   REQUIRES A REAL DOMAIN POINTED TO THIS SERVER  ║"
echo "  ║                                                      ║"
echo "  ║  Mailu needs:                                       ║"
echo "  ║    - A valid domain (e.g. yourdomain.com)           ║"
echo "  ║    - DNS: A record for mail.yourdomain.com          ║"
echo "  ║    - DNS: MX record pointing to mail.yourdomain.com ║"
echo "  ║    - Ports 25, 80, 443, 587, 993 open              ║"
echo "  ║                                                      ║"
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

section "Step 2: Enter Mailu Configuration"
echo ""
read -rp "  Enter your mail domain (e.g. yourdomain.com): " MAIL_DOMAIN
[ -z "$MAIL_DOMAIN" ] && error "Domain cannot be empty."
read -rp "  Enter mail server hostname (e.g. mail.yourdomain.com): " MAIL_HOSTNAME
[ -z "$MAIL_HOSTNAME" ] && error "Hostname cannot be empty."
ADMIN_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
info "Domain   : $MAIL_DOMAIN"
info "Hostname : $MAIL_HOSTNAME"

section "Step 3: Checking Dependencies"
apt update -y
for pkg in docker.io; do
    if ! command -v docker &> /dev/null; then
        apt install -y "$pkg"
        systemctl enable --now docker
    fi
done
if ! docker compose version &> /dev/null; then
    apt install -y docker-compose-v2 || apt install -y docker-compose
fi
info "Dependencies ready."

section "Step 4: Preparing Directory"
MAILU_DIR="/root/docker/mailu"
if [ -d "$MAILU_DIR" ]; then
    warn "Removing old directory $MAILU_DIR..."
    rm -rf "$MAILU_DIR"
fi
mkdir -p "$MAILU_DIR"/{certs,core,filter,data,dkim,overrides,webmail,redis}
cd "$MAILU_DIR" || error "Cannot navigate to $MAILU_DIR"
info "Directory ready: $MAILU_DIR"

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
SECRET_KEY=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 16)

section "Step 5: Creating .env & docker-compose.yml"
cat > "$MAILU_DIR/.env" <<EOF
SECRET_KEY=$SECRET_KEY
SUBNET=192.168.203.0/24
DOMAIN=$MAIL_DOMAIN
HOSTNAMES=$MAIL_HOSTNAME
POSTMASTER=admin
TLS_FLAVOR=letsencrypt
AUTH_RATELIMIT_EXEMPTIONS=
DISABLE_STATISTICS=False
ADMIN=true
WEBMAIL=roundcube
WEBDAV=none
ANTIVIRUS=clamav
ANTISPAM_NETWORKS=
PASSWORD_SCHEME=PBKDF2
EOF

cat > "$MAILU_DIR/docker-compose.yml" <<EOF
version: '3'

services:
  front:
    image: ghcr.io/mailu/nginx:2.0
    restart: unless-stopped
    env_file: .env
    logging: &logging
      driver: journald
      options:
        tag: mailu
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

  redis:
    image: redis:alpine
    restart: unless-stopped
    volumes:
      - ./redis:/data
    logging: *logging

  imap:
    image: ghcr.io/mailu/dovecot:2.0
    restart: unless-stopped
    env_file: .env
    volumes:
      - ./data:/data
      - ./overrides/dovecot:/overrides:ro
    depends_on:
      - front
    logging: *logging

  smtp:
    image: ghcr.io/mailu/postfix:2.0
    restart: unless-stopped
    env_file: .env
    volumes:
      - ./data:/data
      - ./overrides/postfix:/overrides:ro
    depends_on:
      - front
      - resolver
    logging: *logging

  antispam:
    image: ghcr.io/mailu/rspamd:2.0
    restart: unless-stopped
    env_file: .env
    depends_on:
      - front
      - redis
    volumes:
      - ./filter:/var/lib/rspamd
      - ./overrides/rspamd:/overrides:ro
    logging: *logging

  admin:
    image: ghcr.io/mailu/admin:2.0
    restart: unless-stopped
    env_file: .env
    volumes:
      - ./data:/data
      - ./dkim:/dkim
    depends_on:
      - redis
    logging: *logging

  webmail:
    image: ghcr.io/mailu/roundcube:2.0
    restart: unless-stopped
    env_file: .env
    volumes:
      - ./webmail:/data
    depends_on:
      - imap
    logging: *logging

  resolver:
    image: ghcr.io/mailu/unbound:2.0
    restart: unless-stopped
    env_file: .env
    logging: *logging
EOF
info "Configuration created."

section "Step 6: Pulling & Starting Mailu"
docker compose pull
docker compose up -d

section "Step 7: Creating Admin Account"
sleep 20
docker compose exec -T admin flask mailu admin admin "$MAIL_DOMAIN" "$ADMIN_PASS" --mode=ifmissing 2>/dev/null \
    && info "Admin account created." \
    || warn "Admin creation failed — create manually via webmail."

section "Step 8: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    for port in 25 80 443 465 587 143 993 110 995; do
        ufw allow "$port"/tcp &>/dev/null || true
    done
    info "UFW: mail ports opened."
else
    warn "UFW not found — skipping firewall rules."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Mailu Webmail in your browser:           ║"
echo "  ║      👉  https://$MAIL_HOSTNAME/webmail             ║"
echo "  ║                                                      ║"
echo "  ║  🔑  Admin Panel:                                   ║"
echo "  ║      URL      : https://$MAIL_HOSTNAME/admin        ║"
echo "  ║      Username : admin@$MAIL_DOMAIN"
echo "  ║      Password : $ADMIN_PASS"
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
