#!/bin/bash
#
# ============================================================
#   Netbird Self-Hosted Auto-Installer (with Dex OIDC)
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
echo "  ║       Netbird Self-Hosted Auto-Installer         ║"
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
NB_DIR="/root/docker/netbird"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^netbird' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
    info "Containers removed."
else
    info "No existing Netbird containers found."
fi
if [ -d "$NB_DIR" ]; then
    warn "Removing existing configuration at $NB_DIR..."
    rm -rf "$NB_DIR"
    info "Configuration removed."
fi
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
mkdir -p "$NB_DIR/dex" "$NB_DIR/management" "$NB_DIR/signal" "$NB_DIR/config"
cd "$NB_DIR" || error "Cannot navigate to $NB_DIR"
info "Directory ready: $NB_DIR"

section "Step 6: Detecting Server IP"
WAN_IP=$(curl -4 -s --max-time 5 https://ifconfig.me || curl -4 -s --max-time 5 https://api4.ipify.org || hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
info "Detected IP: $WAN_IP"

section "Step 7: Generating Credentials & Config"
info "Installing apache2-utils for password hashing..."
apt-get install -y apache2-utils -qq

NB_ADMIN_EMAIL="admin@netbird.local"
NB_ADMIN_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 16)
NB_CLIENT_SECRET=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)
NB_TURN_SECRET=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)
NB_ADMIN_HASH=$(htpasswd -bnBC 10 "" "$NB_ADMIN_PASS" | tr -d ':\n')

info "Admin Email    : $NB_ADMIN_EMAIL"
info "Admin Password : $NB_ADMIN_PASS"

# Write Dex OIDC config with placeholder — python3 replaces it safely
# so the bcrypt $ signs are never expanded by bash
cat > "$NB_DIR/dex/config.yaml" <<EOF
issuer: http://$WAN_IP:5556/dex
storage:
  type: memory
web:
  http: 0.0.0.0:5556
oauth2:
  skipApprovalScreen: true
enablePasswordDB: true
staticClients:
  - id: netbird
    redirectURIs:
      - http://$WAN_IP:8089/callback
      - http://$WAN_IP:8089/silent-callback
    name: NetBird
    secret: $NB_CLIENT_SECRET
staticPasswords:
  - email: $NB_ADMIN_EMAIL
    hash: BCRYPT_PLACEHOLDER
    username: admin
    userID: "08a8684b-db88-4b73-90a9-3cd1661f5466"
EOF

python3 -c "
import sys
path = sys.argv[1]
h    = sys.argv[2]
with open(path) as f:
    c = f.read()
c = c.replace('BCRYPT_PLACEHOLDER', h)
with open(path, 'w') as f:
    f.write(c)
" "$NB_DIR/dex/config.yaml" "$NB_ADMIN_HASH"
info "Dex OIDC config created."

# Write management.json to config dir (mounted as /etc/netbird inside container)
cat > "$NB_DIR/config/management.json" <<EOF
{
  "Stuns": [{"Proto": "udp", "URI": "stun:stun.cloudflare.com:3478", "Username": "", "Password": null}],
  "TURNConfig": {
    "Turns": [],
    "CredentialsTTL": "12h",
    "Secret": "$NB_TURN_SECRET",
    "TimeBasedCredentials": false
  },
  "Signal": {"Proto": "http", "URI": "$WAN_IP:10000", "Username": "", "Password": null},
  "Datadir": "/var/lib/netbird/",
  "HttpConfig": {
    "Address": "0.0.0.0:8080",
    "AuthIssuer": "http://$WAN_IP:5556/dex",
    "AuthAudience": "netbird",
    "AuthClientID": "netbird",
    "OIDCConfigEndpoint": "http://netbird-dex:5556/dex/.well-known/openid-configuration"
  },
  "IdpManagerConfig": null,
  "DeviceAuthorizationFlow": null
}
EOF
info "Management config created."

cat > "$NB_DIR/docker-compose.yml" <<EOF
services:
  netbird-dex:
    image: dexidp/dex:latest
    container_name: netbird-dex
    restart: unless-stopped
    ports:
      - "5556:5556"
    volumes:
      - ./dex:/etc/dex
    command: ["dex", "serve", "/etc/dex/config.yaml"]

  netbird-signal:
    image: netbirdio/signal:latest
    container_name: netbird-signal
    restart: unless-stopped
    ports:
      - "10000:10000"
    volumes:
      - ./signal:/var/lib/netbird

  netbird-management:
    image: netbirdio/management:latest
    container_name: netbird-management
    restart: unless-stopped
    ports:
      - "8080:8080"
    volumes:
      - ./management:/var/lib/netbird
      - ./config:/etc/netbird
    command: [
      "--port", "8080",
      "--log-file", "console",
      "--disable-anonymous-metrics=true",
      "--single-account-mode-domain=netbird.local",
      "--dns-domain=netbird.selfhosted"
    ]
    depends_on:
      - netbird-signal
      - netbird-dex

  netbird-dashboard:
    image: netbirdio/dashboard:latest
    container_name: netbird-dashboard
    restart: unless-stopped
    ports:
      - "8089:80"
    environment:
      - USE_AUTH0=false
      - AUTH_AUDIENCE=netbird
      - AUTH_CLIENT_ID=netbird
      - AUTH_AUTHORITY=http://$WAN_IP:5556/dex
      - AUTH_REDIRECT_URI=http://$WAN_IP:8089/callback
      - AUTH_SILENT_REDIRECT_URI=http://$WAN_IP:8089/silent-callback
      - AUTH_SUPPORTED_SCOPES=openid profile email
      - NETBIRD_MGMT_API_ENDPOINT=http://$WAN_IP:8080
      - NETBIRD_SIGNAL_URL=grpc://$WAN_IP:10000
    depends_on:
      - netbird-management
      - netbird-dex
EOF
info "docker-compose.yml created."

section "Step 8: Starting Netbird + Dex"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

section "Step 9: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    ufw allow 8089/tcp
    ufw allow 8080/tcp
    ufw allow 10000/tcp
    ufw allow 5556/tcp
    info "UFW: ports 8089, 8080, 10000, 5556 opened."
else
    warn "UFW not found — skipping firewall rule."
fi

section "Step 10: Verifying Containers"
sleep 8
RUNNING=$(docker ps --format '{{.Names}}' | grep -E 'netbird' || true)
if [ -z "$RUNNING" ]; then
    warn "Containers may not have started. Check: docker logs netbird-management"
else
    info "Containers running: $RUNNING"
fi

section "Step 11: Health Check"
info "Waiting for Netbird Dashboard to be ready on port 8089..."
HEALTH_OK=0
for i in $(seq 1 12); do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 http://127.0.0.1:8089 2>/dev/null || echo "000")
    if echo "$STATUS" | grep -qE '^(200|301|302|303)$'; then
        info "Port 8089 is responding (HTTP $STATUS) — Netbird Dashboard is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 8089 2>/dev/null; then
        warn "Port 8089 is open but HTTP did not respond. Service may still be starting."
        warn "Check logs: docker logs netbird-dashboard"
    else
        warn "Port 8089 is NOT responding after 60s."
        warn "Check logs: docker logs netbird-dashboard"
        docker logs --tail 20 netbird-dashboard 2>&1 || true
    fi
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open Netbird Dashboard in your browser:       ║"
echo "  ║      👉  http://$SERVER_IP:8089                    ║"
echo "  ║                                                      ║"
echo "  ║  🔑  Login Credentials (save these!):              ║"
echo "  ║      Email    : $NB_ADMIN_EMAIL                     ║"
echo "  ║      Password : $NB_ADMIN_PASS                      ║"
echo "  ║                                                      ║"
echo "  ║  🔐  Identity Provider (Dex OIDC):                 ║"
echo "  ║      http://$SERVER_IP:5556/dex                    ║"
echo "  ║                                                      ║"
echo "  ║  📡  Signal Server  : $WAN_IP:10000                ║"
echo "  ║  ⚙️   Management API : $WAN_IP:8080                 ║"
echo "  ║                                                      ║"
echo "  ║  📱  Install Netbird client on peers:               ║"
echo "  ║      https://netbird.io/downloads                   ║"
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
