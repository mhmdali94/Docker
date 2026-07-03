#!/bin/bash
# ============================================================
#   Supabase (self-hosted) Auto-Installer
#   Made by: Mohammed Ali Elshikh | prismatechwork.com
#   ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️
# ============================================================
set -e

info()    { echo -e "\e[32m[INFO]\e[0m $*"; }
warn()    { echo -e "\e[33m[WARN]\e[0m $*"; }
error()   { echo -e "\e[31m[ERROR]\e[0m $*"; exit 1; }
section() { echo -e "\n\e[36m========== $* ==========\e[0m"; }

clear
echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║   Supabase (self-hosted) Auto-Installer"
echo "  ║   Made by: Mohammed Ali Elshikh"
echo "  ║   prismatechwork.com"
echo "  ║"
echo "  ║   ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║  ⚠️   DEMO / TESTING USE ONLY                        ║"
echo "  ║  Supabase runs ~12 containers (needs 4 GB+ RAM).    ║"
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

section "Step 3: Checking Docker Compose V2 & git"
if ! docker compose version &> /dev/null; then
    warn "Docker Compose V2 not found. Installing..."
    apt update -y && apt install -y docker-compose-v2 || apt install -y docker-compose
fi
if ! command -v git &> /dev/null; then
    warn "git not found. Installing..."
    apt update -y && apt install -y git
fi
info "Docker Compose: $(docker compose version)"

section "Step 4: Cleaning Up Existing Containers & Data"
SERVICE_DIR="/root/docker/supabase"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^(supabase-|realtime-dev)' || true)
if [ -n "$EXISTING" ]; then
    warn "Stopping and removing existing Supabase containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
fi
if [ -d "$SERVICE_DIR" ]; then
    warn "Removing existing configuration at $SERVICE_DIR..."
    rm -rf "$SERVICE_DIR"
fi
docker network prune -f &>/dev/null || true
info "Cleanup complete."

section "Step 5: Fetching Supabase Docker Sources"
mkdir -p "$SERVICE_DIR"
git clone --depth 1 https://github.com/supabase/supabase.git /tmp/supabase-src || error "Failed to clone supabase repo."
cp -r /tmp/supabase-src/docker/. "$SERVICE_DIR/"
rm -rf /tmp/supabase-src
cd "$SERVICE_DIR" || error "Cannot navigate to $SERVICE_DIR"
info "Sources ready: $SERVICE_DIR"

section "Step 6: Generating Secrets & .env"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
POSTGRES_PASSWORD=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)
JWT_SECRET=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 40)
DASHBOARD_PASSWORD=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
SECRET_KEY_BASE=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 64)
VAULT_ENC_KEY=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)

b64url() { openssl base64 -A | tr '+/' '-_' | tr -d '='; }
jwt_sign() {
    local role="$1"
    local iat exp header payload data sig
    iat=$(date +%s)
    exp=$((iat + 315360000))
    header=$(printf '{"alg":"HS256","typ":"JWT"}' | b64url)
    payload=$(printf '{"role":"%s","iss":"supabase","iat":%s,"exp":%s}' "$role" "$iat" "$exp" | b64url)
    data="$header.$payload"
    sig=$(printf '%s' "$data" | openssl dgst -sha256 -hmac "$JWT_SECRET" -binary | b64url)
    printf '%s.%s' "$data" "$sig"
}
ANON_KEY=$(jwt_sign anon)
SERVICE_ROLE_KEY=$(jwt_sign service_role)

cp .env.example .env
set_env() { sed -i "s|^$1=.*|$1=$2|" .env; }
set_env POSTGRES_PASSWORD "$POSTGRES_PASSWORD"
set_env JWT_SECRET "$JWT_SECRET"
set_env ANON_KEY "$ANON_KEY"
set_env SERVICE_ROLE_KEY "$SERVICE_ROLE_KEY"
set_env DASHBOARD_USERNAME "supabase"
set_env DASHBOARD_PASSWORD "$DASHBOARD_PASSWORD"
set_env SECRET_KEY_BASE "$SECRET_KEY_BASE"
set_env VAULT_ENC_KEY "$VAULT_ENC_KEY"
set_env KONG_HTTP_PORT "8200"
set_env KONG_HTTPS_PORT "8447"
set_env SITE_URL "http://$SERVER_IP:8200"
set_env API_EXTERNAL_URL "http://$SERVER_IP:8200"
set_env SUPABASE_PUBLIC_URL "http://$SERVER_IP:8200"
info ".env configured."

section "Step 7: Starting Supabase"
warn "Pulling ~12 images — this takes a while on first install..."
docker compose pull || warn "Some pulls failed — compose up will retry."
docker compose up -d || error "Failed to start Supabase. Check output above."

section "Step 8: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    ufw allow 8200/tcp
    info "UFW: port 8200/tcp opened."
else
    warn "UFW not found — skipping firewall rules."
fi

section "Step 9: Verifying Containers"
sleep 15
RUNNING=$(docker ps --format '{{.Names}}' | grep -c '^supabase' || true)
info "Supabase containers running: $RUNNING"

section "Step 10: Health Check"
info "Waiting for Supabase API gateway on port 8200 (first start takes several minutes)..."
HEALTH_OK=0
for i in $(seq 1 48); do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://127.0.0.1:8200 2>/dev/null || echo "000")
    if [ "$STATUS" != "000" ]; then
        info "Kong gateway is responding (HTTP $STATUS). ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/48 — waiting 10s..."
    sleep 10
    echo " retrying"
done
[ "$HEALTH_OK" -eq 0 ] && warn "Not responding yet. Check: cd $SERVICE_DIR && docker compose logs"

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  ⚡  Supabase Studio:  http://$SERVER_IP:8200"
echo "  ║  🔑  Dashboard login: supabase / $DASHBOARD_PASSWORD"
echo "  ║"
echo "  ║  🔗  API URL:   http://$SERVER_IP:8200"
echo "  ║  🔑  anon key:        $ANON_KEY"
echo "  ║  🔑  service_role key: $SERVICE_ROLE_KEY"
echo "  ║  🗄️   Postgres password: $POSTGRES_PASSWORD"
echo "  ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️"
echo "  ║       Made by: Mohammed Ali Elshikh"
echo "  ║       prismatechwork.com"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║  🚀  Need production setup?                         ║"
echo "  ║      👨‍💻  Mohammed Ali Elshikh | prismatechwork.com"
echo "  ║  ☕  USDT (TRC-20): TCSZTkXvhibdrFre5sdTsFLRQ6d6yQkd2i"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
