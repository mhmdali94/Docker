#!/bin/bash
#
# ============================================================
#   NetBird Self-Hosted Auto-Installer
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
echo "  ║       NetBird Self-Hosted Auto-Installer         ║"
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
apt update -y && apt install -y curl jq
info "Dependencies OK."

section "Step 5: Cleaning Up Existing Containers"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E 'netbird' || true)
if [ -n "$EXISTING" ]; then
    warn "Removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
else
    info "No existing NetBird containers found."
fi
docker network prune -f &>/dev/null || true

section "Step 6: Detecting Server IP & Domain"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
[ -z "$SERVER_IP" ] && error "Could not detect server IP."
NB_DOMAIN="${SERVER_IP}.nip.io"
info "Server IP : $SERVER_IP"
info "Domain    : $NB_DOMAIN"

section "Step 7: Preparing Directories"
NB_DIR="/root/docker/netbird"
if [ -d "$NB_DIR" ]; then
    warn "Removing old directory $NB_DIR..."
    rm -rf "$NB_DIR"
fi
mkdir -p "$NB_DIR/management" "$NB_DIR/caddy" "$NB_DIR/dex-data"
chmod 777 "$NB_DIR/dex-data"
cd "$NB_DIR" || error "Cannot navigate to $NB_DIR"
info "Directory ready: $NB_DIR"

section "Step 8: Generating Secrets"
TURN_SECRET=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)
TURN_USER="netbird"
TURN_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)
DEX_CLIENT_SECRET=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)
ADMIN_EMAIL="admin@netbird.local"
ADMIN_PASS="changeme2024"
apt install -y python3-bcrypt &>/dev/null
ADMIN_HASH=$(python3 -c "import bcrypt; print(bcrypt.hashpw(b'${ADMIN_PASS}', bcrypt.gensalt(10)).decode())")
[ -z "$ADMIN_HASH" ] && error "Failed to generate bcrypt hash. Ensure python3-bcrypt is installed."
info "Secrets generated."

section "Step 9: Creating Management Config"
cat > "$NB_DIR/management/management.json" <<EOF
{
  "Stuns": [
    {
      "Proto": "udp",
      "URI": "stun:${NB_DOMAIN}:3478",
      "Username": "",
      "Password": null
    }
  ],
  "TURNConfig": {
    "TimeBasedCredentials": false,
    "CredentialsTTL": "12h0m0s",
    "Secret": "${TURN_SECRET}",
    "Turns": [
      {
        "Proto": "udp",
        "URI": "turn:${NB_DOMAIN}:3478",
        "Username": "${TURN_USER}",
        "Password": "${TURN_PASS}"
      }
    ]
  },
  "Signal": {
    "Proto": "https",
    "URI": "${NB_DOMAIN}:10000",
    "Username": "",
    "Password": null
  },
  "Datadir": "/var/lib/netbird/",
  "HttpConfig": {
    "Address": "0.0.0.0:8080",
    "AuthIssuer": "https://${NB_DOMAIN}/dex",
    "AuthAudience": "netbird-client",
    "AuthKeysLocation": "http://dex:5556/dex/keys",
    "AuthUserIDClaim": "sub"
  },
  "IdpManagerConfig": {
    "ManagerType": "none"
  },
  "DeviceAuthorizationFlow": null,
  "PKCEAuthorizationFlow": {
    "ProviderConfig": {
      "ClientID": "netbird-client",
      "ClientSecret": "${DEX_CLIENT_SECRET}",
      "Scope": "openid profile email offline_access",
      "TokenEndpoint": "https://${NB_DOMAIN}/dex/token",
      "AuthorizationEndpoint": "https://${NB_DOMAIN}/dex/auth",
      "DeviceAuthorizationEndpoint": "",
      "UseIDToken": false
    }
  }
}
EOF
info "management.json created."

section "Step 10: Creating Dex OIDC Config"
cat > "$NB_DIR/dex.yaml" <<EOF
issuer: https://${NB_DOMAIN}/dex

storage:
  type: sqlite3
  config:
    file: /var/dex/dex.db

web:
  http: 0.0.0.0:5556

logger:
  level: info

oauth2:
  skipApprovalScreen: true
  responseTypes:
    - code

staticClients:
  - id: netbird-client
    redirectURIs:
      - 'https://${NB_DOMAIN}/callback'
      - 'http://localhost:53000'
    name: 'NetBird'
    secret: ${DEX_CLIENT_SECRET}

enablePasswordDB: true
staticPasswords:
  - email: "${ADMIN_EMAIL}"
    hash: "${ADMIN_HASH}"
    username: "admin"
    userID: "08a8684b-db88-4b73-90a9-3cd1661f5466"
EOF
info "dex.yaml created."

section "Step 11: Creating Coturn Config"
cat > "$NB_DIR/turnserver.conf" <<EOF
listening-port=3478
external-ip=${SERVER_IP}
min-port=49152
max-port=65535
verbose
fingerprint
lt-cred-mech
server-name=netbird
realm=${NB_DOMAIN}
user=${TURN_USER}:${TURN_PASS}
log-file=stdout
no-software-attribute
EOF
info "turnserver.conf created."

section "Step 12: Creating Caddy Reverse Proxy Config"
cat > "$NB_DIR/caddy/Caddyfile" <<EOF
{
  auto_https disable_redirects
  local_certs
}

${NB_DOMAIN} {
  tls internal

  @dex path /dex/*
  handle @dex {
    reverse_proxy dex:5556
  }

  @grpc {
    protocol grpc
  }
  handle @grpc {
    reverse_proxy h2c://signal:10000
  }

  handle /api/* {
    reverse_proxy management:8080
  }

  handle {
    reverse_proxy dashboard:80
  }
}
EOF
info "Caddyfile created."

section "Step 13: Creating docker-compose.yml"
cat > "$NB_DIR/docker-compose.yml" <<EOF
services:
  caddy:
    image: caddy:latest
    container_name: netbird-caddy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "10000:10000"
    volumes:
      - ./caddy/Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config
    networks:
      - netbird-net

  signal:
    image: netbirdio/signal:latest
    container_name: netbird-signal
    restart: unless-stopped
    networks:
      - netbird-net

  management:
    image: netbirdio/management:latest
    container_name: netbird-management
    restart: unless-stopped
    volumes:
      - ./management:/var/lib/netbird
    command:
      - --config=/var/lib/netbird/management.json
      - --port=8080
      - --log-file=console
      - --log-level=info
      - --disable-anonymous-metrics=true
      - --single-account-mode-domain=${NB_DOMAIN}
      - --dns-domain=netbird.selfhosted
    networks:
      - netbird-net

  dashboard:
    image: netbirdio/dashboard:latest
    container_name: netbird-dashboard
    restart: unless-stopped
    environment:
      - AUTH_AUDIENCE=netbird-client
      - AUTH_CLIENT_ID=netbird-client
      - AUTH_CLIENT_SECRET=${DEX_CLIENT_SECRET}
      - AUTH_AUTHORITY=https://${NB_DOMAIN}/dex
      - USE_AUTH0=false
      - AUTH_SUPPORTED_SCOPES=openid profile email offline_access
      - NETBIRD_MGMT_API_ENDPOINT=https://${NB_DOMAIN}
      - NETBIRD_MGMT_GRPC_API_ENDPOINT=https://${NB_DOMAIN}
      - AUTH_REDIRECT_URI=/callback
      - AUTH_SILENT_REDIRECT_URI=/silent-callback
      - NGINX_SSL_PORT=443
    networks:
      - netbird-net

  dex:
    image: dexidp/dex:latest
    container_name: netbird-dex
    restart: unless-stopped
    command: ["dex", "serve", "/etc/dex/config.yaml"]
    volumes:
      - ./dex.yaml:/etc/dex/config.yaml
      - ./dex-data:/var/dex
    networks:
      - netbird-net

  coturn:
    image: coturn/coturn:latest
    container_name: netbird-coturn
    restart: unless-stopped
    network_mode: host
    volumes:
      - ./turnserver.conf:/etc/coturn/turnserver.conf

volumes:
  caddy_data:
  caddy_config:

networks:
  netbird-net:
    driver: bridge
EOF
info "docker-compose.yml created."

section "Step 14: Starting NetBird"
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    if docker compose version &> /dev/null; then
        docker compose up -d && break
    else
        docker-compose up -d && break
    fi
    warn "Attempt $attempt/$MAX_RETRIES failed."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed to start. Run manually: cd $NB_DIR && docker compose up -d"
done

section "Step 15: Verifying Containers"
sleep 8
RUNNING=$(docker ps --format '{{.Names}}' | grep -E 'netbird' || true)
if [ -z "$RUNNING" ]; then
    warn "Containers may not have started. Check: docker logs netbird-management"
else
    info "Containers running: $RUNNING"
fi

section "Step 16: Health Check"
info "Waiting for NetBird dashboard to be ready..."
HEALTH_OK=0
for i in $(seq 1 18); do
    if curl -sk --max-time 5 "https://${NB_DOMAIN}" &>/dev/null; then
        info "Dashboard is responding — NetBird is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/18 — waiting 10s..."
    sleep 10
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    warn "Dashboard not yet responding. It may still be starting."
    warn "Check logs: docker logs netbird-management"
    docker logs --tail 15 netbird-management 2>&1 || true
fi

section "Step 17: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw allow 10000/tcp
    ufw allow 3478/udp
    ufw allow 49152:65535/udp
    info "UFW: ports 80, 443, 10000/tcp and 3478, 49152-65535/udp opened."
else
    warn "UFW not found — skipping firewall rules."
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open NetBird Dashboard:                        ║"
echo "  ║      👉  https://${NB_DOMAIN}"
echo "  ║                                                      ║"
echo "  ║  ⚠️  Accept the self-signed cert warning            ║"
echo "  ║                                                      ║"
echo "  ║  🔑  Login Credentials (Dex):                      ║"
echo "  ║      Email    : ${ADMIN_EMAIL}"
echo "  ║      Password : ${ADMIN_PASS}"
echo "  ║                                                      ║"
echo "  ║  📡  NetBird Client Setup Key:                     ║"
echo "  ║      Get setup keys from the dashboard after login  ║"
echo "  ║                                                      ║"
echo "  ║  🔄  TURN Server : ${NB_DOMAIN}:3478"
echo "  ║  📶  Signal      : ${NB_DOMAIN}:10000"
echo "  ║  🛠️  Management  : https://${NB_DOMAIN}/api"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh | prismatechwork.com                   ║"
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
