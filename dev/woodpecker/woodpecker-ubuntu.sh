#!/bin/bash
#
# ============================================================
#   Woodpecker CI Auto-Installer
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
echo "  ║       Woodpecker CI Auto-Installer               ║"
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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E 'woodpecker' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing Woodpecker containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
WP_DIR="/root/docker/woodpecker"
if [ -d "$WP_DIR" ]; then
    warn "Removing old directory $WP_DIR..."
    rm -rf "$WP_DIR"
fi
mkdir -p "$WP_DIR/server-data" "$WP_DIR/agent-data"
cd "$WP_DIR" || error "Cannot navigate to $WP_DIR"
info "Directory ready: $WP_DIR"

section "Step 6: Generating Credentials & docker-compose.yml"
WP_SECRET=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)
SERVER_IP_SETUP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
info "Agent secret generated."
warn "NOTE: Woodpecker CI requires OAuth via Gitea, GitHub, GitLab, or Forgejo."
warn "      Edit docker-compose.yml and set WOODPECKER_GITEA_* (or other provider) vars."
warn "      See: https://woodpecker-ci.org/docs/administration/vcs/overview"

cat > "$WP_DIR/docker-compose.yml" <<EOF
services:
  woodpecker-server:
    image: woodpeckerci/woodpecker-server:latest
    container_name: woodpecker-server
    restart: unless-stopped
    ports:
      - "8093:8000"
      - "9003:9000"
    environment:
      WOODPECKER_OPEN: "true"
      WOODPECKER_HOST: http://$SERVER_IP_SETUP:8093
      WOODPECKER_AGENT_SECRET: $WP_SECRET
      # --- Configure ONE of the following OAuth providers ---
      # WOODPECKER_GITEA: "true"
      # WOODPECKER_GITEA_URL: http://YOUR_GITEA_HOST:3100
      # WOODPECKER_GITEA_CLIENT: YOUR_OAUTH_CLIENT_ID
      # WOODPECKER_GITEA_SECRET: YOUR_OAUTH_CLIENT_SECRET
    volumes:
      - ./server-data:/var/lib/woodpecker
    networks:
      - woodpecker-net

  woodpecker-agent:
    image: woodpeckerci/woodpecker-agent:latest
    container_name: woodpecker-agent
    restart: unless-stopped
    depends_on:
      - woodpecker-server
    environment:
      WOODPECKER_SERVER: woodpecker-server:9000
      WOODPECKER_AGENT_SECRET: $WP_SECRET
    volumes:
      - ./agent-data:/etc/woodpecker
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - woodpecker-net

networks:
  woodpecker-net:
    driver: bridge
EOF
info "docker-compose.yml created."
warn "Edit $WP_DIR/docker-compose.yml to configure your OAuth provider before first login."

section "Step 7: Starting Woodpecker CI"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 8: Verifying Containers"
sleep 6
RUNNING=$(docker ps --format '{{.Names}}' | grep -E 'woodpecker' || true)
if [ -z "$RUNNING" ]; then
    warn "Containers may not have started. Check: docker logs woodpecker-server"
else
    info "Containers running: $RUNNING"
fi

section "Step 9: Health Check"
info "Waiting for Woodpecker CI to be ready on port 8093..."
HEALTH_OK=0
for i in $(seq 1 12); do
    if curl -sf --max-time 3 http://127.0.0.1:8093 &>/dev/null; then
        info "Port 8093 is responding — Woodpecker CI is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 8093 2>/dev/null; then
        warn "Port 8093 is open but HTTP did not respond. Service may still be starting."
        warn "Check logs: docker logs woodpecker-server"
    else
        warn "Port 8093 is NOT responding after 60s."
        warn "Check logs: docker logs woodpecker-server"
        docker logs --tail 20 woodpecker-server 2>&1 || true
    fi
fi

section "Step 10: Opening Firewall Port 8093"
if command -v ufw &> /dev/null; then
    ufw allow 8093/tcp
    info "UFW: port 8093/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Woodpecker CI in your browser:           ║"
echo "  ║      👉  http://$SERVER_IP:8093"
echo "  ║                                                      ║"
echo "  ║  🔑  Agent Secret (save this!):                    ║"
echo "  ║      $WP_SECRET"
echo "  ║                                                      ║"
echo "  ║  ⚙️  Configure OAuth provider in:                  ║"
echo "  ║      $WP_DIR/docker-compose.yml"
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
