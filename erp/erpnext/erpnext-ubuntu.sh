#!/bin/bash
#
# ============================================================
#   ERPNext Auto-Installer
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
echo "  ║         ERPNext Auto-Installer                   ║"
echo "  ║         Made by: Mohammed Ali Elshikh           ║"
echo "  ║         prismatechwork.com                      ║"
echo "  ║                                                  ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️         ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║                                                      ║"
echo "  ║  ⚠️   DEMO / TESTING USE ONLY                        ║"
echo "  ║                                                      ║"
echo "  ║  ⏳  First startup takes 10-15 minutes for ERPNext  ║"
echo "  ║      site initialization and app installation.     ║"
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
for C in erpnext erpnext-db erpnext-redis; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${C}$" || true)
    if [ -n "$EXISTING" ]; then
        warn "Removing existing container: $C"
        docker rm -f "$C" 2>/dev/null || true
    fi
done
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
EN_DIR="/root/docker/erpnext"
if [ -d "$EN_DIR" ]; then
    warn "Removing old directory $EN_DIR..."
    rm -rf "$EN_DIR"
fi
mkdir -p "$EN_DIR/sites" "$EN_DIR/logs"
cd "$EN_DIR" || error "Cannot navigate to $EN_DIR"
info "Directory ready: $EN_DIR"

section "Step 6: Generating Credentials & Writing Config"
DB_ROOT_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
ADMIN_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
info "Admin Password  : $ADMIN_PASS"
warn "First startup takes 10-15 minutes for site initialization."

cat > "$EN_DIR/init.sh" <<EOF
#!/bin/bash
set -e
SITE="erpnext.localhost"
BENCH_DIR="/home/frappe/frappe-bench"

echo "[ERPNext] Waiting for MariaDB..."
until python3 -c "import socket; socket.create_connection(('erpnext-db', 3306), timeout=3)" 2>/dev/null; do
    sleep 3
done
echo "[ERPNext] MariaDB is ready."

if [ ! -f "\$BENCH_DIR/sites/\$SITE/site_config.json" ]; then
    echo "[ERPNext] Creating site \$SITE (takes 10-15 minutes)..."
    cd "\$BENCH_DIR"
    bench new-site "\$SITE" \\
        --mariadb-root-password "$DB_ROOT_PASS" \\
        --admin-password "$ADMIN_PASS" \\
        --db-host erpnext-db \\
        --no-mariadb-socket
    bench --site "\$SITE" install-app erpnext
    bench --site "\$SITE" migrate
    echo "[ERPNext] Site initialized."
fi

echo "\$SITE" > "\$BENCH_DIR/sites/currentsite.txt"
cd "\$BENCH_DIR"
exec gunicorn -b 0.0.0.0:8080 frappe.app:application --preload
EOF
chmod +x "$EN_DIR/init.sh"

cat > "$EN_DIR/docker-compose.yml" <<EOF
services:
  erpnext-db:
    image: mariadb:10.6
    container_name: erpnext-db
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: $DB_ROOT_PASS
      MYSQL_DATABASE: erpnext
      MYSQL_USER: erpnext
      MYSQL_PASSWORD: $DB_PASS
    volumes:
      - ./db:/var/lib/mysql
    command: --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci --skip-character-set-client-handshake

  erpnext-redis:
    image: redis:7-alpine
    container_name: erpnext-redis
    restart: unless-stopped

  erpnext:
    image: frappe/erpnext:v15
    container_name: erpnext
    restart: unless-stopped
    depends_on:
      - erpnext-db
      - erpnext-redis
    ports:
      - "8119:8080"
    environment:
      DB_HOST: erpnext-db
      DB_PORT: 3306
      REDIS_CACHE: redis://erpnext-redis:6379/0
      REDIS_QUEUE: redis://erpnext-redis:6379/1
    volumes:
      - ./sites:/home/frappe/frappe-bench/sites
      - ./logs:/home/frappe/frappe-bench/logs
      - ./init.sh:/usr/local/bin/erpnext-init.sh
    entrypoint: ["/bin/bash", "/usr/local/bin/erpnext-init.sh"]
EOF
info "docker-compose.yml and init.sh created."

section "Step 7: Starting ERPNext"
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    if docker compose version &> /dev/null; then
        docker compose up -d && break
    else
        docker-compose up -d && break
    fi
    warn "Docker pull failed on attempt $attempt/$MAX_RETRIES (registry may be temporarily unavailable)."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed to start after $MAX_RETRIES attempts. Run manually: cd $PWD && docker compose up -d"
done

section "Step 8: Verifying Container"
sleep 20
RUNNING=$(docker ps --format '{{.Names}}' | grep -E '^erpnext$' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs erpnext"
else
    info "Container running: $RUNNING"
fi

section "Step 9: Health Check"
warn "ERPNext site initialization takes 10-15 minutes. Checking every 30s (30 attempts)..."
HEALTH_OK=0
for i in $(seq 1 30); do
    if curl -sf --max-time 5 http://127.0.0.1:8119 &>/dev/null; then
        info "Port 8119 is responding — ERPNext is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/30 — waiting 30s (init in progress)..."
    sleep 30
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    warn "ERPNext may still be initializing. Check: docker logs erpnext"
    warn "Try accessing http://<server-ip>:8119 in 10-15 more minutes."
fi

section "Step 10: Opening Firewall Port 8119"
if command -v ufw &> /dev/null; then
    ufw allow 8119/tcp
    info "UFW: port 8119/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  ERPNext URL:                                  ║"
echo "  ║      http://$SERVER_IP:8119"
echo "  ║                                                      ║"
echo "  ║  🔑  Login Credentials:                            ║"
echo "  ║      Username : administrator"
echo "  ║      Password : $ADMIN_PASS"
echo "  ║                                                      ║"
echo "  ║  ⏳  If not ready, wait 10-15 min for init.        ║"
echo "  ║      Monitor: docker logs erpnext                   ║"
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
