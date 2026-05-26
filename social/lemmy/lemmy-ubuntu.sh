#!/bin/bash
# ============================================================
#   Lemmy Auto-Installer
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
echo "  ║     Lemmy Auto-Installer                        ║"
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

section "Step 4: Configuration"
echo ""
echo "  ⚠️  Lemmy requires a real domain for federation."
echo ""
read -rp "  Enter your domain (e.g. lemmy.example.com): " LEMMY_DOMAIN
[ -z "$LEMMY_DOMAIN" ] && error "Domain is required."
read -rp "  Admin username [admin]: " LEMMY_ADMIN
LEMMY_ADMIN="${LEMMY_ADMIN:-admin}"
ADMIN_PASS=$(openssl rand -base64 12 | tr -d '=+/')
DB_PASS=$(openssl rand -hex 16)
PICTRS_KEY=$(openssl rand -hex 32)
info "Domain: $LEMMY_DOMAIN | Admin: $LEMMY_ADMIN"

section "Step 5: Cleaning Up Existing Containers"
for cname in lemmy lemmy-ui lemmy-postgres lemmy-pictrs lemmy-proxy; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    [ -n "$EXISTING" ] && warn "Removing $cname..." && docker rm -f "$cname" 2>/dev/null || true
done

section "Step 6: Preparing Directory"
APP_DIR="/root/docker/lemmy"
mkdir -p "$APP_DIR/pictrs"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 7: Writing lemmy.hjson"
cat > "$APP_DIR/lemmy.hjson" <<EOF
{
  hostname: "${LEMMY_DOMAIN}"
  bind: "0.0.0.0"
  port: 8536
  tls_enabled: false
  database: {
    host: "lemmy-postgres"
    port: 5432
    database: "lemmy"
    user: "lemmy"
    password: "${DB_PASS}"
    pool_size: 5
  }
  pictrs: {
    url: "http://lemmy-pictrs:8080/"
    api_key: "${PICTRS_KEY}"
  }
  setup: {
    admin_username: "${LEMMY_ADMIN}"
    admin_password: "${ADMIN_PASS}"
    site_name: "My Lemmy Instance"
  }
}
EOF
info "lemmy.hjson created."

section "Step 8: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  lemmy:
    image: dessalines/lemmy:latest
    container_name: lemmy
    restart: unless-stopped
    environment:
      RUST_LOG: "warn"
    volumes:
      - ./lemmy.hjson:/config/config.hjson
    depends_on:
      - lemmy-postgres
      - lemmy-pictrs

  lemmy-ui:
    image: dessalines/lemmy-ui:latest
    container_name: lemmy-ui
    restart: unless-stopped
    ports:
      - "8536:1234"
    environment:
      LEMMY_UI_LEMMY_INTERNAL_HOST: lemmy:8536
      LEMMY_UI_LEMMY_EXTERNAL_HOST: ${LEMMY_DOMAIN}:8536
      LEMMY_UI_HTTPS: "false"
    depends_on:
      - lemmy

  lemmy-postgres:
    image: postgres:15-alpine
    container_name: lemmy-postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: lemmy
      POSTGRES_USER: lemmy
      POSTGRES_PASSWORD: ${DB_PASS}
    volumes:
      - ./postgres:/var/lib/postgresql/data

  lemmy-pictrs:
    image: asonix/pictrs:0.4
    container_name: lemmy-pictrs
    restart: unless-stopped
    environment:
      PICTRS__API_KEY: ${PICTRS_KEY}
      PICTRS__MEDIA__VIDEO_CODEC: "vp9"
    volumes:
      - ./pictrs:/mnt
    user: 991:991
EOF
info "docker-compose.yml created."

section "Step 9: Starting Lemmy"
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start."
else
    docker-compose up -d || error "Failed to start."
fi

section "Step 10: Health Check (~60s)"
info "Waiting for Lemmy to be ready..."
for i in $(seq 1 18); do
    if curl -sf --max-time 5 http://127.0.0.1:8536 &>/dev/null; then
        info "Lemmy is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/18 — waiting 10s..."
    sleep 10
    echo " retrying"
done

section "Step 11: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 8536/tcp
    info "UFW: port 8536 opened."
else
    warn "UFW not found — skipping."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🐀  Lemmy:                                        ║"
echo "  ║      👉  http://$LEMMY_DOMAIN:8536"
echo "  ║                                                      ║"
echo "  ║  🔑  Admin credentials:                            ║"
printf  "  ║      Username: %-38s║\n" "$LEMMY_ADMIN"
printf  "  ║      Password: %-38s║\n" "$ADMIN_PASS"
echo "  ║                                                      ║"
echo "  ║  ⚠️  For federation: point DNS A record to this IP  ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
