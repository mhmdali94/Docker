#!/bin/bash
#
# ============================================================
#   Authelia SSO & 2FA Gateway Auto-Installer
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
echo "  ║       Authelia SSO & 2FA Auto-Installer          ║"
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

section "Step 4: Checking Dependencies"
apt update -y && apt install -y openssl
info "Dependencies OK."

section "Step 5: Cleaning Up Existing Containers"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E 'authelia' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing Authelia containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 6: Preparing Directory"
AL_DIR="/root/docker/authelia"
if [ -d "$AL_DIR" ]; then
    warn "Removing old directory $AL_DIR..."
    rm -rf "$AL_DIR"
fi
mkdir -p "$AL_DIR/config"
cd "$AL_DIR" || error "Cannot navigate to $AL_DIR"
info "Directory ready: $AL_DIR"

section "Step 7: Generating Credentials & Configuration"
AL_JWT_SECRET=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 64)
AL_SESSION_SECRET=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 64)
AL_STORAGE_KEY=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 64)
AL_ADMIN_PASS_HASH=$(docker run --rm authelia/authelia:latest authelia crypto hash generate argon2 --password 'changeme2024' 2>/dev/null | grep 'Digest:' | awk '{print $2}' || echo '$argon2id$v=19$m=65536,t=3,p=4$PLACEHOLDER')
info "Admin User     : authelia"
info "Admin Password : changeme2024  (CHANGE THIS AFTER FIRST LOGIN)"

cat > "$AL_DIR/config/configuration.yml" <<EOF
---
theme: dark
jwt_secret: $AL_JWT_SECRET

default_redirection_url: http://localhost:9091

server:
  host: 0.0.0.0
  port: 9091

log:
  level: info

totp:
  issuer: authelia.local

authentication_backend:
  file:
    path: /config/users_database.yml
    password:
      algorithm: argon2id
      iterations: 3
      memory: 65536
      parallelism: 4
      key_length: 32
      salt_length: 16

access_control:
  default_policy: deny
  rules:
    - domain: "*.local"
      policy: two_factor

session:
  name: authelia_session
  secret: $AL_SESSION_SECRET
  expiration: 3600
  inactivity: 300
  domain: localhost

regulation:
  max_retries: 3
  find_time: 120
  ban_time: 300

storage:
  local:
    path: /config/db.sqlite3
  encryption_key: $AL_STORAGE_KEY

notifier:
  filesystem:
    filename: /config/notification.txt
EOF

cat > "$AL_DIR/config/users_database.yml" <<EOF
---
users:
  authelia:
    displayname: "Authelia Admin"
    password: "\$argon2id\$v=19\$m=65536,t=3,p=4\$bXlzYWx0c3RyaW5nMTI\$K6s1onBxqMGRxvHb8C1T2HE9GyCepUiSfxpY3f1Lv+A"
    email: admin@example.com
    groups:
      - admins
      - dev
EOF
warn "Default password is 'changeme2024'. Update $AL_DIR/config/users_database.yml with a proper hash."

cat > "$AL_DIR/docker-compose.yml" <<EOF
services:
  authelia-redis:
    image: redis:alpine
    container_name: authelia-redis
    restart: unless-stopped
    volumes:
      - ./redis-data:/data
    networks:
      - authelia-net

  authelia:
    image: authelia/authelia:latest
    container_name: authelia
    restart: unless-stopped
    depends_on:
      - authelia-redis
    ports:
      - "9091:9091"
    volumes:
      - ./config:/config
    environment:
      TZ: UTC
    networks:
      - authelia-net

networks:
  authelia-net:
    driver: bridge
EOF
info "Configuration and docker-compose.yml created."

section "Step 8: Starting Authelia"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 9: Verifying Containers"
sleep 6
RUNNING=$(docker ps --format '{{.Names}}' | grep -E 'authelia' || true)
if [ -z "$RUNNING" ]; then
    warn "Containers may not have started. Check: docker logs authelia"
else
    info "Containers running: $RUNNING"
fi

section "Step 10: Health Check"
info "Waiting for Authelia to be ready on port 9091..."
HEALTH_OK=0
for i in $(seq 1 12); do
    if curl -sf --max-time 3 http://127.0.0.1:9091/api/health &>/dev/null; then
        info "Port 9091 is responding — Authelia is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 9091 2>/dev/null; then
        warn "Port 9091 is open but health check did not respond. Service may still be starting."
        warn "Check logs: docker logs authelia"
    else
        warn "Port 9091 is NOT responding after 60s."
        warn "Check logs: docker logs authelia"
        docker logs --tail 20 authelia 2>&1 || true
    fi
fi

section "Step 11: Opening Firewall Port 9091"
if command -v ufw &> /dev/null; then
    ufw allow 9091/tcp
    info "UFW: port 9091/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Authelia in your browser:                ║"
echo "  ║      👉  http://$SERVER_IP:9091"
echo "  ║                                                      ║"
echo "  ║  🔑  Default Credentials:                          ║"
echo "  ║      Username : authelia"
echo "  ║      Password : changeme2024"
echo "  ║                                                      ║"
echo "  ║  ⚙️  Edit users in:                                ║"
echo "  ║      $AL_DIR/config/users_database.yml"
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
