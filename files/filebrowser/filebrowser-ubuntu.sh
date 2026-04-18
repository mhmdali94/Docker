#!/bin/bash
#
# ============================================================
#   FileBrowser Auto-Installer
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
echo "  ║       FileBrowser Auto-Installer                 ║"
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

section "Step 4: Cleaning Up Existing Containers & Data"
FILEBROWSER_DIR="/root/docker/filebrowser"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E 'filebrowser' || true)
if [ -n "$EXISTING" ]; then
    warn "Stopping and removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
    info "Containers removed."
else
    info "No existing FileBrowser containers found."
fi
if docker image inspect filebrowser-local &>/dev/null 2>&1; then
    warn "Removing existing filebrowser-local image..."
    docker rmi -f filebrowser-local 2>/dev/null || true
    info "Image removed."
fi
if [ -d "$FILEBROWSER_DIR" ]; then
    warn "Removing existing configuration at $FILEBROWSER_DIR..."
    rm -rf "$FILEBROWSER_DIR"
    info "Configuration removed."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
mkdir -p "$FILEBROWSER_DIR/config"
cd "$FILEBROWSER_DIR" || error "Cannot navigate to $FILEBROWSER_DIR"
info "Directory ready: $FILEBROWSER_DIR"

section "Step 6: Building FileBrowser Image & Generating docker-compose.yml"
cat > "$FILEBROWSER_DIR/Dockerfile" <<'DOCKERFILE'
FROM alpine:latest
RUN apk add --no-cache wget tar && \
    wget -qO /tmp/fb.tar.gz \
      "https://github.com/filebrowser/filebrowser/releases/latest/download/linux-amd64-filebrowser.tar.gz" && \
    tar -xzf /tmp/fb.tar.gz -C /usr/local/bin filebrowser && \
    rm /tmp/fb.tar.gz && \
    chmod +x /usr/local/bin/filebrowser
RUN mkdir -p /tmp/init /tmp/srv && \
    sh -c 'filebrowser -d /tmp/init/fb.db -r /tmp/srv -a 127.0.0.1 -p 18099 >/dev/null 2>&1 & echo $! > /tmp/fb.pid && sleep 8 && kill $(cat /tmp/fb.pid) 2>/dev/null; true' && \
    filebrowser -d /tmp/init/fb.db users update admin --password "AdminDemo1234"
EXPOSE 80
CMD ["filebrowser", "-d", "/config/filebrowser.db", "-r", "/srv", "-a", "0.0.0.0", "-p", "80"]
DOCKERFILE

info "Admin User     : admin"
info "Admin Password : AdminDemo1234"
info "Building FileBrowser image (downloads binary from GitHub)..."
docker build --no-cache -t filebrowser-local "$FILEBROWSER_DIR" || error "Docker build failed."
info "Image built successfully."

info "Pre-populating database with admin/admin credentials..."
TEMP_CID=$(docker create filebrowser-local)
docker cp "$TEMP_CID":/tmp/init/fb.db "$FILEBROWSER_DIR/config/filebrowser.db" || error "Failed to extract database from image."
docker rm "$TEMP_CID" &>/dev/null
info "Database ready."

cat > "$FILEBROWSER_DIR/docker-compose.yml" <<EOF
services:
  filebrowser:
    image: filebrowser-local
    container_name: filebrowser
    restart: unless-stopped
    user: "0:0"
    ports:
      - "8082:80"
    volumes:
      - /root:/srv
      - ./config:/config
EOF
info "docker-compose.yml created."

section "Step 7: Starting FileBrowser"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 8: Opening Firewall Port 8082"
if command -v ufw &> /dev/null; then
    ufw allow 8082/tcp
    info "UFW: port 8082/tcp opened."
else
    warn "UFW not found — skipping firewall rule."
fi

section "Step 9: Verifying Container"
sleep 4
RUNNING=$(docker ps --format '{{.Names}}' | grep -E 'filebrowser' || true)
if [ -z "$RUNNING" ]; then
    warn "Container may not have started. Check: docker logs filebrowser"
else
    info "Container running: $RUNNING"
fi

section "Step 10: Health Check"
info "Waiting for FileBrowser to be ready on port 8082..."
HEALTH_OK=0
for i in $(seq 1 12); do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 http://127.0.0.1:8082 2>/dev/null || echo "000")
    if echo "$STATUS" | grep -qE '^(200|301|302|303)$'; then
        info "Port 8082 is responding (HTTP $STATUS) — FileBrowser is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 8082 2>/dev/null; then
        warn "Port 8082 is open but HTTP did not respond. Service may still be starting."
        warn "Check logs: docker logs filebrowser"
    else
        warn "Port 8082 is NOT responding after 60s."
        warn "Check logs: docker logs filebrowser"
        docker logs --tail 20 filebrowser 2>&1 || true
    fi
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open FileBrowser in your browser:             ║"
echo "  ║      👉  http://$SERVER_IP:8082"
echo "  ║                                                      ║"
echo "  ║  🔑  Login Credentials (save these!):              ║"
echo "  ║      Username : admin                               ║"
echo "  ║      Password : AdminDemo1234"
echo "  ║                                                      ║"
echo "  ║  ⚠️  Change credentials immediately after login!    ║"
echo "  ║                                                      ║"
echo "  ║  📂  Browse files in: /root                         ║"
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
