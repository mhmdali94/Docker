#!/bin/bash
# ============================================================
#   Caddy Auto-Installer
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
echo "  ║     Caddy Auto-Installer                        ║"
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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^caddy$" || true)
[ -n "$EXISTING" ] && warn "Removing existing container..." && docker rm -f caddy 2>/dev/null || true

section "Step 5: Preparing Directory"
APP_DIR="/root/docker/caddy"
mkdir -p "$APP_DIR/config" "$APP_DIR/data" "$APP_DIR/site"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 6: Writing Default Caddyfile"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
cat > "$APP_DIR/config/Caddyfile" <<EOF
# Caddy reverse proxy configuration
# Edit this file to add your services
# Caddy auto-reloads on change

# Example: proxy to a local service
# yourdomain.com {
#     reverse_proxy localhost:8080
# }

# Example: serve static files
# yourdomain.com {
#     root * /srv
#     file_server
# }

# Listening on port 80 for now (no domain configured)
:80 {
    respond "Caddy is running! Edit /root/docker/caddy/config/Caddyfile to configure your services." 200
}
EOF
info "Default Caddyfile created."

section "Step 7: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<'EOF'
services:
  caddy:
    image: caddy:2-alpine
    container_name: caddy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "2019:2019"
    volumes:
      - ./config/Caddyfile:/etc/caddy/Caddyfile
      - ./data:/data
      - ./site:/srv
    network_mode: host
EOF
info "docker-compose.yml created."

section "Step 8: Starting Caddy"
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start. Run: cd $APP_DIR && docker compose up -d"
else
    docker-compose up -d || error "Failed to start. Run: cd $APP_DIR && docker-compose up -d"
fi

section "Step 9: Health Check"
info "Waiting for Caddy to be ready..."
for i in $(seq 1 6); do
    if curl -sf --max-time 3 http://127.0.0.1:80 &>/dev/null; then
        info "Caddy is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/6 — waiting 3s..."
    sleep 3
    echo " retrying"
done

section "Step 10: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 80/tcp
    ufw allow 443/tcp
    info "UFW: ports 80 and 443 opened."
else
    warn "UFW not found — skipping."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🌐  Caddy Reverse Proxy:                          ║"
echo "  ║      👉  http://$SERVER_IP"
echo "  ║                                                      ║"
echo "  ║  ⚙️   Admin API:  http://$SERVER_IP:2019"
echo "  ║                                                      ║"
echo "  ║  📝  Config: $APP_DIR/config/Caddyfile"
echo "  ║      Edit to add your services — auto-reloads!     ║"
echo "  ║                                                      ║"
echo "  ║  🔐  Auto HTTPS: Point a domain at this server,   ║"
echo "  ║      add it to Caddyfile, and TLS is automatic.    ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
