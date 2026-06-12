#!/bin/bash
# ============================================================
#   Open Source POS Auto-Installer
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
echo "  ║     Open Source POS Auto-Installer              ║"
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

section "Step 4: Cleaning Up Existing Containers"
for cname in opensourcepos opensourcepos-mysql; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    [ -n "$EXISTING" ] && warn "Removing $cname..." && docker rm -f "$cname" 2>/dev/null || true
done

section "Step 5: Preparing Directory"
APP_DIR="/root/docker/opensourcepos"
mkdir -p "$APP_DIR"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

DB_PASS=$(openssl rand -hex 16)

section "Step 6: Writing Configuration Files"
# opensourcepos has no public Docker Hub image, and their own Dockerfile
# skips composer install (it targets a pre-built CI image, not local builds).
# We write our own Dockerfile + entrypoint that build correctly from source.

# --- entrypoint.sh ---
cat > "$APP_DIR/entrypoint.sh" << 'ENTRYPOINT'
#!/bin/bash
set -e

# CI4 requires a persistent encryption key — generate once and reuse on restart
KEY_FILE="/app/writable/.app_key"
if [ ! -f "$KEY_FILE" ]; then
    openssl rand -hex 32 > "$KEY_FILE"
fi
APP_KEY=$(cat "$KEY_FILE")

# Write CodeIgniter 4 .env with DB connection from environment variables
{
    printf "CI_ENVIRONMENT = production\n"
    printf "app.encryptionKey = %s\n" "$APP_KEY"
    printf "app.baseURL = \n"
    printf "database.default.hostname = %s\n" "${OSWEB_DB_HOSTNAME:-localhost}"
    printf "database.default.database = %s\n" "${OSWEB_DB_DATABASE:-ospos}"
    printf "database.default.username = %s\n" "${OSWEB_DB_USERNAME:-ospos}"
    printf "database.default.password = %s\n" "${OSWEB_DB_PASSWORD}"
    printf "database.default.DBDriver = MySQLi\n"
    printf "database.default.port = 3306\n"
} > /app/.env
chown www-data:www-data /app/.env

# Ensure CI4 writable directories have correct permissions
chown -R www-data:www-data /app/writable
chmod -R 775 /app/writable

# Wait for MySQL to accept connections before starting Apache
echo "[OSPOS] Waiting for MySQL..."
until php -r "
try {
    new PDO(
        'mysql:host=' . getenv('OSWEB_DB_HOSTNAME') . ';dbname=' . getenv('OSWEB_DB_DATABASE'),
        getenv('OSWEB_DB_USERNAME'),
        getenv('OSWEB_DB_PASSWORD')
    );
    exit(0);
} catch (Exception \$e) { exit(1); }
" 2>/dev/null; do
    sleep 2
done
echo "[OSPOS] MySQL ready."

cd /app

# Run migrations
php spark migrate --all --no-interaction

# Seed default data (admin user + settings) only on first install
TABLE_EXISTS=$(php -r "
try {
    \$pdo = new PDO(
        'mysql:host=' . getenv('OSWEB_DB_HOSTNAME') . ';dbname=' . getenv('OSWEB_DB_DATABASE'),
        getenv('OSWEB_DB_USERNAME'),
        getenv('OSWEB_DB_PASSWORD')
    );
    \$r = \$pdo->query(\"SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = '\" . getenv('OSWEB_DB_DATABASE') . \"' AND TABLE_NAME = 'ospos_users'\");
    echo \$r->fetchColumn();
} catch (Exception \$e) { echo 0; }
" 2>/dev/null)

if [ "$TABLE_EXISTS" = "0" ] || [ -z "$TABLE_EXISTS" ]; then
    echo "[OSPOS] Seeding default data..."
    php spark db:seed Database_Seeder 2>/dev/null || true
fi

exec apache2-foreground
ENTRYPOINT
chmod +x "$APP_DIR/entrypoint.sh"
info "entrypoint.sh created."

# --- Dockerfile ---
cat > "$APP_DIR/Dockerfile" << 'DOCKERFILE'
FROM php:8.2-apache

RUN apt-get update -qq && apt-get install -y -qq \
        git unzip curl \
        libpng-dev libjpeg-dev libfreetype6-dev \
        libzip-dev libicu-dev libonig-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install mysqli pdo pdo_mysql gd zip intl mbstring \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sS https://getcomposer.org/installer \
    | php -- --install-dir=/usr/local/bin --filename=composer

RUN git clone --depth=1 https://github.com/opensourcepos/opensourcepos.git /app

WORKDIR /app

# Install PHP dependencies (vendor/ is gitignored, must be built)
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Serve from CI4's public/ directory with rewrite support
RUN printf '<VirtualHost *:80>\n\
    DocumentRoot /app/public\n\
    <Directory /app/public>\n\
        Options -Indexes +FollowSymLinks\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
</VirtualHost>\n' > /etc/apache2/sites-enabled/000-default.conf

RUN chown -R www-data:www-data /app

COPY entrypoint.sh /entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
DOCKERFILE
info "Dockerfile created."

# --- docker-compose.yml ---
cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  opensourcepos:
    build: .
    image: opensourcepos:local
    container_name: opensourcepos
    restart: unless-stopped
    ports:
      - "8888:80"
    environment:
      OSWEB_DB_HOSTNAME: opensourcepos-mysql
      OSWEB_DB_USERNAME: ospos
      OSWEB_DB_PASSWORD: ${DB_PASS}
      OSWEB_DB_DATABASE: ospos
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
info "docker-compose.yml created."

section "Step 7: Building & Starting Open Source POS"
warn "Building from source — first run takes 3-5 minutes..."
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    if docker compose version &>/dev/null; then
        docker compose up -d --build && break
    else
        docker-compose up -d --build && break
    fi
    warn "Attempt $attempt/$MAX_RETRIES failed."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed after $MAX_RETRIES attempts. Run manually: cd $APP_DIR && docker compose up -d --build"
done

section "Step 8: Health Check (~60s for first start)"
info "Waiting for Open Source POS to be ready..."
for i in $(seq 1 18); do
    if curl -s --max-time 5 http://127.0.0.1:8888 &>/dev/null; then
        info "Open Source POS is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/18 — waiting 10s..."
    sleep 10
    echo " retrying"
done

section "Step 9: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 8888/tcp
    info "UFW: port 8888 opened."
else
    warn "UFW not found — skipping."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
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
echo "  ║                                                      ║"
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
