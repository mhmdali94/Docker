#!/bin/bash
# ============================================================
#   HashiCorp Vault Auto-Installer
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
echo "  ║     HashiCorp Vault Auto-Installer              ║"
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
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^vault$" || true)
[ -n "$EXISTING" ] && warn "Removing existing container..." && docker rm -f vault 2>/dev/null || true

section "Step 5: Preparing Directory"
APP_DIR="/root/docker/vault"
mkdir -p "$APP_DIR/config" "$APP_DIR/data" "$APP_DIR/logs"
cd "$APP_DIR" || error "Cannot navigate to $APP_DIR"
info "Directory ready: $APP_DIR"

section "Step 6: Writing Vault Config"
cat > "$APP_DIR/config/vault.hcl" <<'EOF'
ui = true

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = true
}

storage "file" {
  path = "/vault/data"
}

api_addr = "http://0.0.0.0:8200"
EOF
info "vault.hcl created."

section "Step 7: Writing docker-compose.yml"
cat > "$APP_DIR/docker-compose.yml" <<'EOF'
services:
  vault:
    image: hashicorp/vault:latest
    container_name: vault
    restart: unless-stopped
    ports:
      - "8200:8200"
    environment:
      VAULT_ADDR: "http://0.0.0.0:8200"
      VAULT_API_ADDR: "http://0.0.0.0:8200"
    cap_add:
      - IPC_LOCK
    volumes:
      - ./config:/vault/config
      - ./data:/vault/data
      - ./logs:/vault/logs
    command: vault server -config=/vault/config/vault.hcl
EOF
info "docker-compose.yml created."

section "Step 8: Starting Vault"
if docker compose version &> /dev/null; then
    docker compose up -d || error "Failed to start. Run: cd $APP_DIR && docker compose up -d"
else
    docker-compose up -d || error "Failed to start. Run: cd $APP_DIR && docker-compose up -d"
fi

section "Step 9: Health Check"
info "Waiting for Vault to be ready..."
for i in $(seq 1 12); do
    if curl -sf --max-time 3 http://127.0.0.1:8200/v1/sys/health &>/dev/null; then
        info "Vault is ready. ✅"
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done

section "Step 10: Initializing Vault"
info "Initializing Vault and saving unseal keys..."
sleep 3
INIT_OUTPUT=$(docker exec vault vault operator init -key-shares=3 -key-threshold=2 2>/dev/null || true)
if [ -n "$INIT_OUTPUT" ]; then
    echo "$INIT_OUTPUT" > "$APP_DIR/vault-init.txt"
    chmod 600 "$APP_DIR/vault-init.txt"
    info "Vault initialized. Keys saved to $APP_DIR/vault-init.txt"
    UNSEAL_1=$(echo "$INIT_OUTPUT" | grep 'Unseal Key 1' | awk '{print $NF}')
    UNSEAL_2=$(echo "$INIT_OUTPUT" | grep 'Unseal Key 2' | awk '{print $NF}')
    ROOT_TOKEN=$(echo "$INIT_OUTPUT" | grep 'Initial Root Token' | awk '{print $NF}')
    docker exec vault vault operator unseal "$UNSEAL_1" &>/dev/null || true
    docker exec vault vault operator unseal "$UNSEAL_2" &>/dev/null || true
    info "Vault unsealed. ✅"
else
    warn "Vault may already be initialized or initialization failed."
    ROOT_TOKEN="(run: docker exec vault vault operator init)"
fi

section "Step 11: Opening Firewall"
if command -v ufw &> /dev/null; then
    ufw allow 8200/tcp
    info "UFW: port 8200 opened."
else
    warn "UFW not found — skipping."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  🔒  HashiCorp Vault:                              ║"
echo "  ║      👉  http://$SERVER_IP:8200"
echo "  ║                                                      ║"
echo "  ║  🔑  Root Token:                                   ║"
printf  "  ║      %-50s║\n" "$ROOT_TOKEN"
echo "  ║                                                      ║"
echo "  ║  📁  Keys saved: $APP_DIR/vault-init.txt"
echo "  ║      ⚠️  Keep this file safe — back it up now!     ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
