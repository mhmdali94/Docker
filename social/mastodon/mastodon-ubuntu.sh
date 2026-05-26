#!/bin/bash
# ============================================================
#   Mastodon Auto-Installer
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
echo "  ║     Mastodon Auto-Installer                     ║"
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
echo "  ⚠️  Mastodon REQUIRES a real domain name to federate with other instances."
echo "  A bare IP address will work for local testing only."
echo ""
read -rp "  Enter your domain (e.g. mastodon.example.com): " LOCAL_DOMAIN
[ -z "$LOCAL_DOMAIN" ] && error "Domain is required."
DB_PASS=$(openssl rand -hex 16)
REDIS_PASS=$(openssl rand -hex 16)
SECRET_KEY_BASE=$(openssl rand -hex 64)
OTP_SECRET=$(openssl rand -hex 64)
info "Domain: $LOCAL_DOMAIN"

section "Step 5: Cleaning Up Existing Containers"
for cname in mastodon mastodon-web mastodon-sidekiq mastodon-streaming mastodon-postgres mastodon-redis; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    [ -n "$EXISTING" ] && warn "Removing $cname..." && docker rm -f "$cname" 2>/dev/null || true
done

section "Step 6: Preparing Directory"
APP_DIR="/root/docker/mastodon"
mkdir -p "$APP_DIR/public/system"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 7: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  mastodon-postgres:
    image: postgres:15-alpine
    container_name: mastodon-postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: mastodon
      POSTGRES_USER: mastodon
      POSTGRES_PASSWORD: ${DB_PASS}
    volumes:
      - ./postgres:/var/lib/postgresql/data

  mastodon-redis:
    image: redis:7-alpine
    container_name: mastodon-redis
    restart: unless-stopped
    command: redis-server --requirepass ${REDIS_PASS}
    volumes:
      - ./redis:/data

  mastodon-web:
    image: tootsuite/mastodon:latest
    container_name: mastodon-web
    restart: unless-stopped
    ports:
      - "3005:3000"
    environment:
      LOCAL_DOMAIN: ${LOCAL_DOMAIN}
      SECRET_KEY_BASE: ${SECRET_KEY_BASE}
      OTP_SECRET: ${OTP_SECRET}
      DB_HOST: mastodon-postgres
      DB_PORT: 5432
      DB_NAME: mastodon
      DB_USER: mastodon
      DB_PASS: ${DB_PASS}
      REDIS_HOST: mastodon-redis
      REDIS_PORT: 6379
      REDIS_PASSWORD: ${REDIS_PASS}
      RAILS_ENV: production
      RAILS_SERVE_STATIC_FILES: "true"
      SINGLE_USER_MODE: "false"
    volumes:
      - ./public/system:/mastodon/public/system
    depends_on:
      - mastodon-postgres
      - mastodon-redis
    command: bash -c "bundle exec rails db:migrate && bundle exec rails server -b 0.0.0.0"

  mastodon-sidekiq:
    image: tootsuite/mastodon:latest
    container_name: mastodon-sidekiq
    restart: unless-stopped
    environment:
      LOCAL_DOMAIN: ${LOCAL_DOMAIN}
      SECRET_KEY_BASE: ${SECRET_KEY_BASE}
      OTP_SECRET: ${OTP_SECRET}
      DB_HOST: mastodon-postgres
      DB_PORT: 5432
      DB_NAME: mastodon
      DB_USER: mastodon
      DB_PASS: ${DB_PASS}
      REDIS_HOST: mastodon-redis
      REDIS_PORT: 6379
      REDIS_PASSWORD: ${REDIS_PASS}
      RAILS_ENV: production
    volumes:
      - ./public/system:/mastodon/public/system
    depends_on:
      - mastodon-postgres
      - mastodon-redis
    command: bundle exec sidekiq

  mastodon-streaming:
    image: tootsuite/mastodon:latest
    container_name: mastodon-streaming
    restart: unless-stopped
    ports:
      - "4000:4000"
    environment:
      LOCAL_DOMAIN: ${LOCAL_DOMAIN}
      DB_HOST: mastodon-postgres
      DB_PORT: 5432
      DB_NAME: mastodon
      DB_USER: mastodon
      DB_PASS: ${DB_PASS}
      REDIS_HOST: mastodon-redis
      REDIS_PORT: 6379
      REDIS_PASSWORD: ${REDIS_PASS}
      RAILS_ENV: production
    depends_on:
      - mastodon-postgres
      - mastodon-redis
    command: node ./streaming
EOF
info "docker-compose.yml created."

section "Step 8: Starting Mastodon"
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start."
else
    docker-compose up -d || error "Failed to start."
fi

section "Step 9: Health Check (~2 min for migrations)"
info "Waiting for Mastodon to be ready..."
for i in $(seq 1 24); do
    if curl -sf --max-time 5 http://127.0.0.1:3005 &>/dev/null; then
        info "Mastodon is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/24 — waiting 10s..."
    sleep 10
    echo " retrying"
done

section "Step 10: Creating Admin User"
info "Creating admin account..."
docker exec mastodon-web bash -c "RAILS_ENV=production bundle exec tootctl accounts create admin --email admin@${LOCAL_DOMAIN} --confirmed --role Owner" 2>/dev/null || warn "Admin creation skipped — may already exist."

section "Step 11: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 3005/tcp
    ufw allow 4000/tcp
    info "UFW: ports 3005 and 4000 opened."
else
    warn "UFW not found — skipping."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🐘  Mastodon:                                     ║"
echo "  ║      👉  http://$LOCAL_DOMAIN:3005"
echo "  ║                                                      ║"
echo "  ║  ⚙️   Admin: http://$LOCAL_DOMAIN:3005/admin"
echo "  ║      User:  admin@$LOCAL_DOMAIN"
echo "  ║      Set password: docker exec mastodon-web bash -c"
echo "  ║      \"RAILS_ENV=production bundle exec tootctl"
echo "  ║       accounts modify admin --reset-password\""
echo "  ║                                                      ║"
echo "  ║  ⚠️  For federation: point DNS A record to this IP  ║"
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
