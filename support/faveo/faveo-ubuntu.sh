#!/bin/bash
# ============================================================
#   Faveo Helpdesk Auto-Installer
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
echo "  ║     Faveo Helpdesk Auto-Installer               ║"
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
for cname in faveo faveo-db faveo-redis; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    [ -n "$EXISTING" ] && warn "Removing $cname..." && docker rm -f "$cname" 2>/dev/null || true
done
if docker image inspect faveo-local &>/dev/null; then
    warn "Removing existing faveo-local image..."
    docker rmi -f faveo-local 2>/dev/null || true
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
APP_DIR="/root/docker/faveo"
mkdir -p "$APP_DIR"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 6: Generating Credentials, Dockerfile & docker-compose.yml"
DB_PASS=$(openssl rand -hex 16)
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
info "Credentials generated."

cat > "$APP_DIR/Dockerfile" <<'DOCKERFILE'
FROM php:8.1-apache
RUN apt-get update && apt-get install -y --no-install-recommends \
        git unzip libzip-dev libpng-dev libjpeg-dev libfreetype6-dev libldap2-dev libicu-dev && \
    docker-php-ext-configure gd --with-jpeg --with-freetype && \
    docker-php-ext-install pdo_mysql mysqli zip gd ldap intl opcache && \
    a2enmod rewrite && rm -rf /var/lib/apt/lists/*
RUN git clone --depth 1 https://github.com/ladybirdweb/faveo-helpdesk.git /var/www/faveo && \
    chown -R www-data:www-data /var/www/faveo
ENV APACHE_DOCUMENT_ROOT=/var/www/faveo/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf && \
    sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
EXPOSE 80
DOCKERFILE

cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  faveo-db:
    image: mariadb:10.11
    container_name: faveo-db
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_PASS}root
      MYSQL_DATABASE: faveo
      MYSQL_USER: faveo
      MYSQL_PASSWORD: ${DB_PASS}
    volumes:
      - ./mariadb:/var/lib/mysql

  faveo:
    image: faveo-local
    container_name: faveo
    restart: unless-stopped
    ports:
      - "8097:80"
    depends_on:
      - faveo-db
EOF
info "Dockerfile and docker-compose.yml created."

section "Step 7: Building & Starting Faveo"
info "Building Faveo from the official repository (source build — takes several minutes)..."
docker build --no-cache -t faveo-local "$APP_DIR" || error "Docker build failed."
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    if docker compose version &>/dev/null; then
        docker compose up -d && break
    else
        docker-compose up -d && break
    fi
    warn "Attempt $attempt/$MAX_RETRIES failed."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed after $MAX_RETRIES attempts."
done

section "Step 8: Health Check"
info "Waiting for Faveo on port 8097..."
HEALTH_OK=0
for i in $(seq 1 12); do
    if curl -s --max-time 3 http://127.0.0.1:8097 &>/dev/null; then
        info "Port 8097 is responding. ✅"; HEALTH_OK=1; break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."; sleep 5; echo " retrying"
done
[ "$HEALTH_OK" -eq 0 ] && warn "Not responding. Check: docker logs faveo"

section "Step 9: Opening Firewall"
if command -v ufw &>/dev/null; then
    ufw allow 8097/tcp; info "UFW: port 8097 opened."
else
    warn "UFW not found — skipping."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🎫  Faveo Helpdesk:                               ║"
echo "  ║      👉  http://$SERVER_IP:8097"
echo "  ║                                                      ║"
echo "  ║  🔑  Complete the setup wizard on first visit:     ║"
echo "  ║      DB Host    : faveo-db"
echo "  ║      DB Name    : faveo"
echo "  ║      DB User    : faveo"
echo "  ║      DB Password: $DB_PASS"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║  🚀  Need production setup?                         ║"
echo "  ║      👨‍💻  Mohammed Ali Elshikh                      ║"
echo "  ║      🌐  prismatechwork.com                         ║"
echo "  ║  ☕  USDT (TRC-20): TCSZTkXvhibdrFre5sdTsFLRQ6d6yQkd2i ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
