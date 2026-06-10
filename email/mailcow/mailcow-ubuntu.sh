#!/bin/bash
#
# ============================================================
#   Mailcow Dockerized Auto-Installer
#   Made by: Mohammed Ali Elshikh | prismatechwork.com
#
#   ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️
#   This script is NOT intended for production use.
#
#   NOTE: Mailcow requires a valid FQDN (hostname) and
#   open ports 25, 80, 443, 587, 993, 995, 4190.
#   A real domain pointing to this server is needed.
# ============================================================

set -e

info()    { echo -e "\e[32m[INFO]\e[0m $*"; }
warn()    { echo -e "\e[33m[WARN]\e[0m $*"; }
error()   { echo -e "\e[31m[ERROR]\e[0m $*"; exit 1; }
section() { echo -e "\n\e[36m========== $* ==========\e[0m"; }

clear
echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║       Mailcow Dockerized Auto-Installer          ║"
echo "  ║       Made by: Mohammed Ali Elshikh             ║"
echo "  ║       prismatechwork.com                        ║"
echo "  ║                                                  ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️         ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║  ⚠️   REQUIRES A REAL DOMAIN POINTED TO THIS SERVER  ║"
echo "  ║                                                      ║"
echo "  ║  Mailcow needs:                                     ║"
echo "  ║    - A valid FQDN hostname (e.g. mail.yourdomain.com)"
echo "  ║    - DNS records: A, MX, PTR                        ║"
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

section "Step 2: Enter Mailcow Hostname"
echo ""
read -rp "  Enter your mail server FQDN (e.g. mail.yourdomain.com): " MAILCOW_HOSTNAME
[ -z "$MAILCOW_HOSTNAME" ] && error "Hostname cannot be empty."
info "Using hostname: $MAILCOW_HOSTNAME"

section "Step 3: Checking Dependencies"
apt update -y
for pkg in git curl docker.io; do
    if ! command -v "${pkg%.*}" &> /dev/null; then
        warn "Installing $pkg..."
        apt install -y "$pkg"
    fi
done
if ! docker compose version &> /dev/null; then
    apt install -y docker-compose-v2 || apt install -y docker-compose
fi
systemctl enable --now docker
info "Dependencies ready."

section "Step 4: Cleaning Up & Cloning Mailcow"
MC_DIR="/opt/mailcow-dockerized"
if [ -d "$MC_DIR" ]; then
    warn "Removing old mailcow directory..."
    docker compose -f "$MC_DIR/docker-compose.yml" down --remove-orphans 2>/dev/null || true
    rm -rf "$MC_DIR"
fi
git clone https://github.com/mailcow/mailcow-dockerized "$MC_DIR"
cd "$MC_DIR" || error "Cannot navigate to $MC_DIR"
info "Repository cloned."

section "Step 5: Generating Mailcow Config"
MAILCOW_TZ=$(timedatectl show --property=Timezone --value 2>/dev/null || echo "UTC")
cat > "$MC_DIR/mailcow.conf" <<EOF
MAILCOW_HOSTNAME=$MAILCOW_HOSTNAME
MAILCOW_PASS_SCHEME=BLF-CRYPT
HTTP_PORT=80
HTTP_BIND=
HTTPS_PORT=443
HTTPS_BIND=
SMTP_PORT=25
SMTPS_PORT=465
SUBMISSION_PORT=587
IMAP_PORT=143
IMAPS_PORT=993
POP_PORT=110
POPS_PORT=995
SIEVE_PORT=4190
TZ=$MAILCOW_TZ
DBNAME=mailcow
DBUSER=mailcow
DBPASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 28)
DBROOT=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 28)
REDISPASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 28)
ACL_ANYONE=disallow
MAILDIR_GC_TIME=1440
LOG_LINES=9999
WATCHDOG_NOTIFY_EMAIL=
SKIP_LETS_ENCRYPT=n
ENABLE_SSL_SNI=n
SKIP_IP_CHECK=n
SKIP_HTTP_VERIFICATION=n
SKIP_UNBOUND_HEALTHCHECK=n
SOGO_EXPIRE_SESSION=480
COMPOSE_PROJECT_NAME=mailcow
DOCKER_COMPOSE_VERSION=native
EOF
info "mailcow.conf generated."

section "Step 6: Pulling & Starting Mailcow"
docker compose pull
docker compose up -d

section "Step 7: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    for port in 25 80 443 465 587 143 993 110 995 4190; do
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
echo "  ║  🌐  Open Mailcow in your browser:                 ║"
echo "  ║      👉  https://$MAILCOW_HOSTNAME"
echo "  ║                                                      ║"
echo "  ║  🔑  Default Login:                                 ║"
echo "  ║      Username : admin                               ║"
echo "  ║      Password : moohoo                              ║"
echo "  ║      (Change immediately after login!)              ║"
echo "  ║                                                      ║"
echo "  ║  📁  Config dir: $MC_DIR                            ║"
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
