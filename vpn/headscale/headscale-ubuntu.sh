#!/bin/bash
#
# ============================================================
#   Headscale (Self-Hosted Tailscale) Auto-Installer
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
echo "  ║       Headscale Auto-Installer                   ║"
echo "  ║       (Self-Hosted Tailscale Control Server)     ║"
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

section "Step 4: Cleaning Up Existing Containers"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^headscale' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing Headscale containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
HS_DIR="/root/docker/headscale"
if [ -d "$HS_DIR" ]; then
    warn "Removing old directory $HS_DIR..."
    rm -rf "$HS_DIR"
fi
mkdir -p "$HS_DIR/config" "$HS_DIR/data"
cd "$HS_DIR" || error "Cannot navigate to $HS_DIR"
info "Directory ready: $HS_DIR"

section "Step 6: Detecting Server IP"
WAN_IP=$(curl -4 -s --max-time 5 https://ifconfig.me || curl -4 -s --max-time 5 https://api4.ipify.org || hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
info "Detected IP: $WAN_IP"

section "Step 7: Generating Config & docker-compose.yml"
cat > "$HS_DIR/config/config.yaml" <<EOF
server_url: http://$WAN_IP:8090
listen_addr: 0.0.0.0:8090
metrics_listen_addr: 0.0.0.0:9090
grpc_listen_addr: 0.0.0.0:50443
grpc_allow_insecure: true
private_key_path: /var/lib/headscale/private.key
noise:
  private_key_path: /var/lib/headscale/noise_private.key
ip_prefixes:
  - 100.64.0.0/10
derp:
  server:
    enabled: false
  urls:
    - https://controlplane.tailscale.com/derpmap/default
  auto_update_enabled: true
  update_frequency: 24h
disable_check_updates: true
ephemeral_node_inactivity_timeout: 30m
db_type: sqlite3
db_path: /var/lib/headscale/db.sqlite
log:
  level: info
dns_config:
  override_local_dns: true
  nameservers:
    - 1.1.1.1
  magic_dns: true
  base_domain: headscale.local
unix_socket: /var/run/headscale/headscale.sock
unix_socket_permission: "0770"
EOF

cat > "$HS_DIR/docker-compose.yml" <<EOF
services:
  headscale:
    image: headscale/headscale:latest
    container_name: headscale
    restart: unless-stopped
    command: serve
    ports:
      - "8090:8090"
      - "9090:9090"
    volumes:
      - ./config:/etc/headscale
      - ./data:/var/lib/headscale
      - ./run:/var/run/headscale

  headscale-ui:
    image: ghcr.io/gurucomputing/headscale-ui:latest
    container_name: headscale-ui
    restart: unless-stopped
    ports:
      - "8091:80"
EOF
info "Config and docker-compose.yml created."

section "Step 8: Starting Headscale"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 9: Verifying Containers"
sleep 6
RUNNING=$(docker ps --format '{{.Names}}' | grep -E 'headscale' || true)
if [ -z "$RUNNING" ]; then
    warn "Containers may not have started. Check: docker logs headscale"
else
    info "Containers running: $RUNNING"
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Headscale UI:                                  ║"
echo "  ║      👉  http://$SERVER_IP:8091"
echo "  ║                                                      ║"
echo "  ║  ⚙️   Headscale API: http://$SERVER_IP:8090"
echo "  ║                                                      ║"
echo "  ║  👤  Create your first user (namespace):           ║"
echo "  ║      docker exec headscale headscale users create myuser"
echo "  ║                                                      ║"
echo "  ║  🔑  Generate auth key for a user:                 ║"
echo "  ║      docker exec headscale headscale preauthkeys create --user myuser"
echo "  ║                                                      ║"
echo "  ║  📱  Connect a Tailscale client:                   ║"
echo "  ║      tailscale up --login-server http://$WAN_IP:8090"
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
