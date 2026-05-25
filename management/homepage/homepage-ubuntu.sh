#!/bin/bash
# ============================================================
#   Homepage Auto-Installer
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
echo "  ║     Homepage Auto-Installer                     ║"
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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^homepage$" || true)
[ -n "$EXISTING" ] && warn "Removing existing container..." && docker rm -f homepage 2>/dev/null || true

section "Step 5: Preparing Directory"
APP_DIR="/root/docker/homepage"
mkdir -p "$APP_DIR/config"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 6: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<'EOF'
services:
  homepage:
    image: ghcr.io/gethomepage/homepage:latest
    container_name: homepage
    restart: unless-stopped
    ports:
      - "3333:3000"
    volumes:
      - ./config:/app/config
      - /var/run/docker.sock:/var/run/docker.sock:ro
EOF
info "docker-compose.yml created."

section "Step 7: Writing Default Config"
cat > "$APP_DIR/config/settings.yaml" <<'EOF'
---
title: My Dashboard
description: Self-hosted services dashboard
theme: dark
color: slate
headerStyle: clean
target: _blank
layout:
  Services:
    style: row
    columns: 4
EOF

cat > "$APP_DIR/config/services.yaml" <<'EOF'
---
- Services:
    - Portainer:
        href: http://{{HOSTNAME}}:9443
        description: Docker Management
        icon: portainer.png
EOF

cat > "$APP_DIR/config/bookmarks.yaml" <<'EOF'
---
- Developer:
    - GitHub:
        - href: https://github.com
    - DockerHub:
        - href: https://hub.docker.com
EOF

cat > "$APP_DIR/config/widgets.yaml" <<'EOF'
---
- greeting:
    text_size: xl
    text: Welcome to your Dashboard
- datetime:
    text_size: xl
    format:
      dateStyle: long
      timeStyle: short
      hour12: true
- resources:
    cpu: true
    memory: true
    disk: /
EOF
info "Default config files created."

section "Step 8: Starting Homepage"
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start. Run: cd $APP_DIR && docker compose up -d"
else
    docker-compose up -d || error "Failed to start. Run: cd $APP_DIR && docker-compose up -d"
fi

section "Step 9: Health Check"
info "Waiting for Homepage to be ready..."
for i in $(seq 1 12); do
    if curl -sf --max-time 3 http://127.0.0.1:3333 &>/dev/null; then
        info "Homepage is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done

section "Step 10: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 3333/tcp
    info "UFW: port 3333 opened."
else
    warn "UFW not found — skipping."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🏠  Homepage Dashboard:                           ║"
echo "  ║      👉  http://$SERVER_IP:3333"
echo "  ║                                                      ║"
echo "  ║  📁  Config files: $APP_DIR/config/"
echo "  ║      services.yaml   — add your services            ║"
echo "  ║      bookmarks.yaml  — add bookmarks               ║"
echo "  ║      widgets.yaml    — configure widgets            ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
