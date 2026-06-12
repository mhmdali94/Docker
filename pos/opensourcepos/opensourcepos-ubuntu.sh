#!/bin/bash
# ============================================================
#   Open Source POS Auto-Installer
#   Made by: Mohammed Ali Elshikh | prismatechwork.com
#   ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️
# ============================================================

G="\e[32m"; Y="\e[33m"; R="\e[31m"; C="\e[36m"; B="\e[1m"; RST="\e[0m"
info()    { echo -e "${G}[INFO]${RST} $*"; }
warn()    { echo -e "${Y}[WARN]${RST} $*"; }
error()   { echo -e "${R}[ERROR]${RST} $*"; exit 1; }
section() { echo -e "\n${C}${B}══════════════════════ $* ══════════════════════${RST}"; }

clear
echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║     Open Source POS Auto-Installer              ║"
echo "  ║     Made by: Mohammed Ali Elshikh              ║"
echo "  ║     prismatechwork.com                         ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️        ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""
echo "  Press ENTER to continue ... Ctrl+C to cancel."
read -rp "" _

# ── Step 0: Privileges ────────────────────────────────────────────────────────
section "Step 0: Checking Privileges"
[ "$EUID" -ne 0 ] && error "Please run as root: sudo bash $0"
info "Running as root. OK."

# ── Step 1: OS ────────────────────────────────────────────────────────────────
section "Step 1: Verifying OS"
[ -f /etc/os-release ] || error "Cannot determine OS."
. /etc/os-release
[ "$ID" = "ubuntu" ] || error "Only Ubuntu is supported. Found: $ID"
{ [ "$VERSION_ID" = "22.04" ] || [ "$VERSION_ID" = "24.04" ]; } \
    || error "Only Ubuntu 22.04/24.04 supported. Found: $VERSION_ID"
info "OS check passed: Ubuntu $VERSION_ID"

# ── Step 2: Docker ────────────────────────────────────────────────────────────
section "Step 2: Checking Docker"
if ! command -v docker &>/dev/null; then
    warn "Docker not found. Installing..."
    apt-get update -qq && apt-get install -y -qq docker.io
    systemctl enable --now docker
    info "Docker installed."
else
    info "Docker: $(docker --version)"
fi

# ── Step 3: Docker Compose ────────────────────────────────────────────────────
section "Step 3: Checking Docker Compose V2"
if ! docker compose version &>/dev/null; then
    warn "Docker Compose V2 not found. Installing..."
    apt-get update -qq \
        && apt-get install -y -qq docker-compose-v2 2>/dev/null \
        || apt-get install -y -qq docker-compose
    info "Docker Compose installed."
else
    info "Docker Compose: $(docker compose version)"
fi

# ── Step 4: Clean up ──────────────────────────────────────────────────────────
section "Step 4: Cleaning Up"
APP_DIR="/root/docker/opensourcepos"

for cname in opensourcepos opensourcepos-mysql; do
    if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -qE "^${cname}$"; then
        warn "Removing container: $cname"
        docker rm -f "$cname" 2>/dev/null || true
    fi
done

# MySQL data must be wiped — the installer generates a new random password each
# run, so an existing data directory would reject the new credentials and leave
# the app stuck forever in "Waiting for MySQL...".
if [ -d "$APP_DIR/mysql" ]; then
    warn "Removing old MySQL data (password is regenerated on each install)..."
    rm -rf "$APP_DIR/mysql"
fi

# ── Step 5: Directory + credentials ──────────────────────────────────────────
section "Step 5: Preparing Directory"
mkdir -p "$APP_DIR"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory: $APP_DIR"

DB_PASS=$(openssl rand -hex 16)
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
info "Server IP: $SERVER_IP"

# ── Step 6: Config files ──────────────────────────────────────────────────────
section "Step 6: Writing Configuration Files"

# ── entrypoint.sh ─────────────────────────────────────────────────────────────
# Single-quoted heredoc — no variable expansion here; variables are runtime shell vars.
cat > "$APP_DIR/entrypoint.sh" << 'ENTRYPOINT'
#!/bin/bash

# CI4 writable dirs are gitignored and must exist before any app code runs.
mkdir -p /app/writable/cache \
         /app/writable/logs \
         /app/writable/session \
         /app/writable/uploads \
         /app/writable/debugbar \
         /app/writable/backup

# Persistent encryption key — kept across container restarts in the writable dir.
KEY_FILE="/app/writable/.app_key"
[ -f "$KEY_FILE" ] || openssl rand -hex 32 > "$KEY_FILE"
APP_KEY=$(cat "$KEY_FILE")

# Writes the canonical .env.  Called twice: once before migrations so spark has
# a valid environment, and once after, because the Convert_to_ci4 migration
# overwrites app.baseURL in .env with the value from ospos_appconfig (localhost).
write_env() {
    {
        printf "CI_ENVIRONMENT = development\n"
        printf "app.encryptionKey = %s\n" "$APP_KEY"
        printf "app.baseURL = %s\n" "${APP_BASE_URL:-http://localhost/}"
        printf "Toolbar.enabled = false\n"
    } > /app/.env
}

write_env
chown -R www-data:www-data /app/writable /app/.env
chmod -R 775 /app/writable

# OSPOS Config/Database.php reads MYSQL_HOST_NAME / MYSQL_USERNAME /
# MYSQL_PASSWORD / MYSQL_DB_NAME — these come from docker-compose environment.
echo "[OSPOS] Waiting for MySQL..."
until php -r "
try {
    \$pdo = new PDO(
        'mysql:host=' . getenv('MYSQL_HOST_NAME') . ';dbname=' . getenv('MYSQL_DB_NAME'),
        getenv('MYSQL_USERNAME'),
        getenv('MYSQL_PASSWORD'),
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );
    \$pdo->query('SELECT 1');
    exit(0);
} catch (Exception \$e) { exit(1); }
" 2>/dev/null; do
    sleep 2
done
# Extra buffer: MySQL accepts TCP before finishing user/DB grants on first init.
sleep 3
echo "[OSPOS] MySQL ready."

cd /app

# Run migrations with development mode so DB errors surface (production mode
# sets DBDebug=false and causes spark to exit with no output on any DB failure).
echo "[OSPOS] Running migrations..."
CI_ENVIRONMENT=development php spark migrate 2>&1 \
    || echo "[OSPOS] Migration warning (continuing)"

# Restore .env — the Convert_to_ci4 migration rewrites app.baseURL to localhost.
write_env

# spark migrate runs as root and creates log files owned root:root (mode 660).
# www-data (Apache) cannot append to those files, causing CI4's exception handler
# to fail silently (empty HTTP 500, no log output).  Fix ownership now.
chown -R www-data:www-data /app/writable /app/.env

echo "[OSPOS] Starting Apache..."
exec apache2-foreground
ENTRYPOINT
chmod +x "$APP_DIR/entrypoint.sh"
info "entrypoint.sh written."

# ── Dockerfile ────────────────────────────────────────────────────────────────
cat > "$APP_DIR/Dockerfile" << 'DOCKERFILE'
FROM php:8.2-apache

RUN apt-get update -qq && apt-get install -y -qq --no-install-recommends \
        git unzip curl \
        libpng-dev libjpeg-dev libfreetype6-dev \
        libzip-dev libicu-dev libonig-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" \
        mysqli pdo pdo_mysql gd zip intl mbstring bcmath \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sS https://getcomposer.org/installer \
    | php -- --install-dir=/usr/local/bin --filename=composer

RUN git clone --depth=1 https://github.com/opensourcepos/opensourcepos.git /app

WORKDIR /app

RUN composer install --no-dev --optimize-autoloader --no-interaction

RUN printf '<VirtualHost *:80>\n\
    ServerName localhost\n\
    DocumentRoot /app/public\n\
    <Directory /app/public>\n\
        Options -Indexes +FollowSymLinks\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
</VirtualHost>\n' > /etc/apache2/sites-enabled/000-default.conf

RUN chown -R www-data:www-data /app

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
DOCKERFILE
info "Dockerfile written."

# ── docker-compose.yml ────────────────────────────────────────────────────────
cat > "$APP_DIR/docker-compose.yml" << EOF
services:
  opensourcepos:
    build: .
    image: opensourcepos:local
    container_name: opensourcepos
    restart: unless-stopped
    ports:
      - "8888:80"
    environment:
      MYSQL_HOST_NAME: opensourcepos-mysql
      MYSQL_USERNAME: ospos
      MYSQL_PASSWORD: ${DB_PASS}
      MYSQL_DB_NAME: ospos
      APP_BASE_URL: http://${SERVER_IP}:8888/
    depends_on:
      - opensourcepos-mysql

  opensourcepos-mysql:
    image: mysql:8.0
    container_name: opensourcepos-mysql
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_PASS}
      MYSQL_DATABASE: ospos
      MYSQL_USER: ospos
      MYSQL_PASSWORD: ${DB_PASS}
    volumes:
      - ./mysql:/var/lib/mysql
    command: --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
EOF
info "docker-compose.yml written."

# ── Step 7: Build & Start ─────────────────────────────────────────────────────
section "Step 7: Building & Starting Open Source POS"
warn "Building from source — first run takes 3–5 minutes..."

MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    if docker compose up -d --build; then
        break
    fi
    warn "Attempt $attempt/$MAX_RETRIES failed."
    if [ "$attempt" -lt "$MAX_RETRIES" ]; then
        info "Retrying in 15s..."
        sleep 15
    else
        error "Build failed after $MAX_RETRIES attempts. Run manually: cd $APP_DIR && docker compose up -d --build"
    fi
done

# ── Step 8: Health check ──────────────────────────────────────────────────────
section "Step 8: Health Check (~90s for first start)"
info "Waiting for Open Source POS to be ready..."
READY=0
for i in $(seq 1 24); do
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 8 \
        "http://127.0.0.1:8888" 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ]; then
        info "Open Source POS is ready — HTTP $HTTP_CODE ✅"
        READY=1
        break
    fi
    echo "  Attempt $i/24 — HTTP $HTTP_CODE — waiting 10s..."
    sleep 10
done
[ "$READY" -eq 0 ] && warn "App did not respond after 240s. Check: docker logs opensourcepos"

# ── Step 9: Firewall ──────────────────────────────────────────────────────────
section "Step 9: Opening Firewall"
if command -v ufw &>/dev/null; then
    ufw allow 8888/tcp 2>/dev/null || true
    info "UFW: port 8888 opened."
else
    warn "UFW not found — skipping."
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🛍️   Open Source POS:                             ║"
echo "  ║      👉  http://$SERVER_IP:8888"
echo "  ║                                                      ║"
echo "  ║  🔑  Default credentials:                          ║"
echo "  ║      Username: admin                                ║"
echo "  ║      Password: pointofsale                         ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  Change the default password after login!       ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║  🚀  Need production setup?                         ║"
echo "  ║      Mohammed Ali Elshikh                          ║"
echo "  ║      prismatechwork.com                            ║"
echo "  ║                                                      ║"
echo "  ║  ☕  Support — USDT (TRC-20 only):                 ║"
echo "  ║      TCSZTkXvhibdrFre5sdTsFLRQ6d6yQkd2i           ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
