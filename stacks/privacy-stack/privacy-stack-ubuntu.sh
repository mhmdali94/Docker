#!/bin/bash
# ============================================================
#   Privacy Stack Auto-Installer (AdGuard + Unbound + WireGuard)
#   Ad-blocking DNS chain + VPN, pre-wired
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
echo "  ║   PRIVACY STACK Auto-Installer"
echo "  ║   WireGuard VPN → AdGuard Home → Unbound"
echo "  ║   VPN clients get ad-blocking, recursive DNS"
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
SERVICE_DIR="/root/docker/privacy-stack"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^ps-(adguard|unbound|wg-easy)$' || true)
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
mkdir -p "$SERVICE_DIR"/{adguard-work,adguard-conf,wg-easy}
cd "$SERVICE_DIR" || error "Cannot navigate to $SERVICE_DIR"
info "Directory ready: $SERVICE_DIR"

section "Step 6: Writing docker-compose.yml (fixed IPs: unbound .2, adguard .3, wg .4)"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
cat > "$SERVICE_DIR/docker-compose.yml" <<EOF
services:
  ps-unbound:
    image: mvance/unbound:latest
    container_name: ps-unbound
    restart: unless-stopped
    networks:
      privacy-net:
        ipv4_address: 10.8.10.2

  ps-adguard:
    image: adguard/adguardhome:latest
    container_name: ps-adguard
    restart: unless-stopped
    depends_on:
      - ps-unbound
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "3053:3000"
      - "8083:80"
    volumes:
      - ./adguard-work:/opt/adguardhome/work
      - ./adguard-conf:/opt/adguardhome/conf
    networks:
      privacy-net:
        ipv4_address: 10.8.10.3

  ps-wg-easy:
    image: ghcr.io/wg-easy/wg-easy:latest
    container_name: ps-wg-easy
    restart: unless-stopped
    depends_on:
      - ps-adguard
    ports:
      - "51820:51820/udp"
      - "51821:51821/tcp"
    environment:
      INIT_ENABLED: "true"
      INIT_HOST: $SERVER_IP
      INIT_PORT: 51820
      INIT_DNS: 10.8.10.3
      DISABLE_IPV6: "true"
    volumes:
      - ./wg-easy:/etc/wireguard
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    sysctls:
      - net.ipv4.ip_forward=1
      - net.ipv4.conf.all.src_valid_mark=1
    networks:
      privacy-net:
        ipv4_address: 10.8.10.4

networks:
  privacy-net:
    driver: bridge
    ipam:
      config:
        - subnet: 10.8.10.0/24
EOF
info "docker-compose.yml created."

section "Step 7: Handling Port 53 (systemd-resolved)"
if ss -ltn 2>/dev/null | grep -q ':53 ' || ss -lun 2>/dev/null | grep -q ':53 '; then
    if systemctl is-active -q systemd-resolved 2>/dev/null; then
        warn "Freeing port 53 from systemd-resolved..."
        mkdir -p /etc/systemd/resolved.conf.d
        printf '[Resolve]\nDNSStubListener=no\nDNS=1.1.1.1\n' > /etc/systemd/resolved.conf.d/adguard.conf
        systemctl restart systemd-resolved || true
        info "systemd-resolved stub listener disabled."
    else
        warn "Port 53 is in use by another service — AdGuard may fail to bind."
    fi
fi

section "Step 8: Starting the Privacy Stack"
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    docker compose up -d && break
    warn "Docker pull failed on attempt $attempt/$MAX_RETRIES."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed to start after $MAX_RETRIES attempts."
done

section "Step 9: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    for p in 53/tcp 53/udp 3053/tcp 8083/tcp 51820/udp 51821/tcp; do ufw allow "$p"; done
    info "UFW: stack ports opened."
else
    warn "UFW not found — skipping firewall rules."
fi

section "Step 10: Health Checks"
sleep 8
for svc in "3053 AdGuard-setup" "51821 WireGuard-UI"; do
    port=${svc%% *}; name=${svc#* }
    OK=0
    for i in $(seq 1 12); do
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 "http://127.0.0.1:$port" 2>/dev/null || echo "000")
        [ "$STATUS" != "000" ] && { info "$name responding (HTTP $STATUS) ✅"; OK=1; break; }
        sleep 5
    done
    [ "$OK" -eq 0 ] && warn "$name not responding yet on port $port."
done
nc -z 127.0.0.1 53 2>/dev/null && info "DNS port 53 is listening. ✅" || warn "DNS port 53 not listening yet."

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║            ✅  PRIVACY STACK READY!                  ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  1️⃣   AdGuard setup wizard: http://$SERVER_IP:3053"
echo "  ║      → set Web interface port 80, DNS port 53"
echo "  ║      → then Settings → DNS → upstream server:"
echo "  ║        10.8.10.2  (the Unbound recursive resolver)"
echo "  ║      Dashboard afterwards: http://$SERVER_IP:8083"
echo "  ║"
echo "  ║  2️⃣   WireGuard UI: http://$SERVER_IP:51821"
echo "  ║      → create the admin in the setup wizard,"
echo "  ║        add clients — their DNS is already 10.8.10.3"
echo "  ║        (AdGuard), so VPN clients get ad-blocking."
echo "  ║"
echo "  ║  Chain: client → WireGuard → AdGuard (filter) → Unbound (recursive)"
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
