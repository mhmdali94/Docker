#!/bin/bash
# ============================================================
#   Media Stack Auto-Installer (Jellyfin + *arr + qBittorrent)
#   Made by: Mohammed Ali Elshikh | prismatechwork.com
#   ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️
# ============================================================
set -e

info()    { echo -e "\e[32m[INFO]\e[0m $*"; }
warn()    { echo -e "\e[33m[WARN]\e[0m $*"; }
error()   { echo -e "\e[31m[ERROR]\e[0m $*"; exit 1; }
section() { echo -e "\n\e[36m========== $* ==========\e[0m"; }

clear
echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║   MEDIA STACK Auto-Installer"
echo "  ║   Jellyfin + Sonarr + Radarr + Prowlarr"
echo "  ║   + qBittorrent + Jellyseerr — pre-wired"
echo "  ║"
echo "  ║   Made by: Mohammed Ali Elshikh | prismatechwork.com"
echo "  ║   ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""
echo "  Press ENTER to continue... Ctrl+C to cancel."
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
fi
info "Docker Compose: $(docker compose version)"

section "Step 4: Cleaning Up Existing Containers & Data"
SERVICE_DIR="/root/docker/media-stack"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^ms-(jellyfin|sonarr|radarr|prowlarr|qbittorrent|jellyseerr)$' || true)
if [ -n "$EXISTING" ]; then
    warn "Stopping and removing existing stack containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
fi
if [ -d "$SERVICE_DIR" ]; then
    warn "Removing existing configuration at $SERVICE_DIR..."
    rm -rf "$SERVICE_DIR"
fi
docker network prune -f &>/dev/null || true
info "Cleanup complete."

section "Step 5: Preparing Directories"
mkdir -p "$SERVICE_DIR"/{jellyfin,sonarr,radarr,prowlarr,qbittorrent,jellyseerr}
mkdir -p "$SERVICE_DIR"/media/{movies,tv,downloads}
chown -R 1000:1000 "$SERVICE_DIR"
cd "$SERVICE_DIR" || error "Cannot navigate to $SERVICE_DIR"
info "Directory ready: $SERVICE_DIR (shared library under ./media)"

section "Step 6: Writing docker-compose.yml"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
cat > "$SERVICE_DIR/docker-compose.yml" <<EOF
services:
  ms-jellyfin:
    image: jellyfin/jellyfin:latest
    container_name: ms-jellyfin
    restart: unless-stopped
    ports:
      - "8096:8096"
    environment:
      JELLYFIN_PublishedServerUrl: http://$SERVER_IP:8096
    volumes:
      - ./jellyfin:/config
      - ./media:/media
    networks: [media-net]

  ms-qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: ms-qbittorrent
    restart: unless-stopped
    ports:
      - "8115:8115"
      - "6881:6881"
      - "6881:6881/udp"
    environment:
      PUID: 1000
      PGID: 1000
      TZ: UTC
      WEBUI_PORT: 8115
    volumes:
      - ./qbittorrent:/config
      - ./media/downloads:/media/downloads
    networks: [media-net]

  ms-prowlarr:
    image: lscr.io/linuxserver/prowlarr:latest
    container_name: ms-prowlarr
    restart: unless-stopped
    ports:
      - "9696:9696"
    environment:
      PUID: 1000
      PGID: 1000
      TZ: UTC
    volumes:
      - ./prowlarr:/config
    networks: [media-net]

  ms-sonarr:
    image: lscr.io/linuxserver/sonarr:latest
    container_name: ms-sonarr
    restart: unless-stopped
    ports:
      - "8989:8989"
    environment:
      PUID: 1000
      PGID: 1000
      TZ: UTC
    volumes:
      - ./sonarr:/config
      - ./media:/media
    networks: [media-net]

  ms-radarr:
    image: lscr.io/linuxserver/radarr:latest
    container_name: ms-radarr
    restart: unless-stopped
    ports:
      - "7878:7878"
    environment:
      PUID: 1000
      PGID: 1000
      TZ: UTC
    volumes:
      - ./radarr:/config
      - ./media:/media
    networks: [media-net]

  ms-jellyseerr:
    image: fallenbagel/jellyseerr:latest
    container_name: ms-jellyseerr
    restart: unless-stopped
    ports:
      - "5056:5055"
    environment:
      TZ: UTC
    volumes:
      - ./jellyseerr:/app/config
    networks: [media-net]

networks:
  media-net:
    driver: bridge
EOF
info "docker-compose.yml created — all services share one network and one /media library."

section "Step 7: Starting the Media Stack"
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    docker compose up -d && break
    warn "Docker pull failed on attempt $attempt/$MAX_RETRIES."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed to start after $MAX_RETRIES attempts."
done

section "Step 8: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    for p in 8096/tcp 8115/tcp 9696/tcp 8989/tcp 7878/tcp 5056/tcp 6881/tcp 6881/udp; do ufw allow "$p"; done
    info "UFW: stack ports opened."
else
    warn "UFW not found — skipping firewall rules."
fi

section "Step 9: Verifying Containers"
sleep 12
RUNNING=$(docker ps --format '{{.Names}}' | grep -c '^ms-' || true)
info "Stack containers running: $RUNNING/6"

section "Step 10: Health Checks"
for svc in "8096 Jellyfin" "8115 qBittorrent" "9696 Prowlarr" "8989 Sonarr" "7878 Radarr" "5056 Jellyseerr"; do
    port=${svc%% *}; name=${svc#* }
    OK=0
    for i in $(seq 1 12); do
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 "http://127.0.0.1:$port" 2>/dev/null || echo "000")
        [ "$STATUS" != "000" ] && { info "$name responding on $port (HTTP $STATUS) ✅"; OK=1; break; }
        sleep 5
    done
    [ "$OK" -eq 0 ] && warn "$name not responding yet on $port — check: docker logs ms-$(echo "$name" | tr '[:upper:]' '[:lower:]')"
done

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  MEDIA STACK READY!                  ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🎬  Jellyfin:    http://$SERVER_IP:8096"
echo "  ║  🔍  Prowlarr:    http://$SERVER_IP:9696"
echo "  ║  📺  Sonarr:      http://$SERVER_IP:8989"
echo "  ║  🎥  Radarr:      http://$SERVER_IP:7878"
echo "  ║  ⬇️   qBittorrent: http://$SERVER_IP:8115  (admin / see: docker logs ms-qbittorrent)"
echo "  ║  🙋  Jellyseerr:  http://$SERVER_IP:5056"
echo "  ║"
echo "  ║  🔗  WIRING (containers reach each other by name):"
echo "  ║   1. Prowlarr → Settings → Apps → add Sonarr (http://ms-sonarr:8989)"
echo "  ║      and Radarr (http://ms-radarr:7878) — indexers sync automatically"
echo "  ║   2. Sonarr/Radarr → Download Clients → qBittorrent"
echo "  ║      host: ms-qbittorrent  port: 8115"
echo "  ║   3. Root folders: /media/tv (Sonarr), /media/movies (Radarr)"
echo "  ║   4. Jellyfin libraries: /media/movies + /media/tv"
echo "  ║   5. Jellyseerr → connect Jellyfin (http://ms-jellyfin:8096)"
echo "  ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️"
echo "  ║       Made by: Mohammed Ali Elshikh | prismatechwork.com"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║  🚀  Need production setup?                         ║"
echo "  ║      👨‍💻  Mohammed Ali Elshikh | prismatechwork.com"
echo "  ║  ☕  USDT (TRC-20): TCSZTkXvhibdrFre5sdTsFLRQ6d6yQkd2i"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
