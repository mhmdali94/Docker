#!/bin/bash
# ============================================================
#   AI Stack Auto-Installer (Ollama + Open WebUI + SearXNG + LiteLLM)
#   Local ChatGPT with web search, one command
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
echo "  ║   AI STACK Auto-Installer"
echo "  ║   Ollama + Open WebUI + SearXNG + LiteLLM"
echo "  ║   Private ChatGPT with live web search"
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
SERVICE_DIR="/root/docker/ai-stack"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^ai-(ollama|webui|searxng|litellm)$' || true)
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

section "Step 5: Preparing Directories & SearXNG Config"
mkdir -p "$SERVICE_DIR"/{ollama,webui,searxng}
cd "$SERVICE_DIR" || error "Cannot navigate to $SERVICE_DIR"
SEARXNG_SECRET=$(openssl rand -hex 32)
cat > "$SERVICE_DIR/searxng/settings.yml" <<CONFIG
use_default_settings: true
server:
  secret_key: "$SEARXNG_SECRET"
  limiter: false
search:
  formats:
    - html
    - json
CONFIG
info "SearXNG configured with JSON output (required for Open WebUI search)."

section "Step 6: Writing docker-compose.yml"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
LITELLM_KEY="sk-$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)"
cat > "$SERVICE_DIR/docker-compose.yml" <<EOF
services:
  ai-ollama:
    image: ollama/ollama:latest
    container_name: ai-ollama
    restart: unless-stopped
    ports:
      - "11434:11434"
    environment:
      OLLAMA_HOST: 0.0.0.0
    volumes:
      - ./ollama:/root/.ollama
    networks: [ai-net]

  ai-searxng:
    image: searxng/searxng:latest
    container_name: ai-searxng
    restart: unless-stopped
    ports:
      - "8081:8080"
    volumes:
      - ./searxng:/etc/searxng
    networks: [ai-net]

  ai-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: ai-webui
    restart: unless-stopped
    depends_on:
      - ai-ollama
      - ai-searxng
    ports:
      - "3210:8080"
    environment:
      OLLAMA_BASE_URL: http://ai-ollama:11434
      ENABLE_RAG_WEB_SEARCH: "true"
      RAG_WEB_SEARCH_ENGINE: searxng
      SEARXNG_QUERY_URL: http://ai-searxng:8080/search?q=<query>
    volumes:
      - ./webui:/app/backend/data
    networks: [ai-net]

  ai-litellm:
    image: ghcr.io/berriai/litellm:main-stable
    container_name: ai-litellm
    restart: unless-stopped
    depends_on:
      - ai-ollama
    ports:
      - "4001:4000"
    command: --model ollama/qwen2.5:0.5b --api_base http://ai-ollama:11434 --port 4000
    environment:
      LITELLM_MASTER_KEY: $LITELLM_KEY
    networks: [ai-net]

networks:
  ai-net:
    driver: bridge
EOF
info "docker-compose.yml created."

section "Step 7: Starting the AI Stack"
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    docker compose up -d && break
    warn "Docker pull failed on attempt $attempt/$MAX_RETRIES."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed to start after $MAX_RETRIES attempts."
done

section "Step 8: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    for p in 3210/tcp 11434/tcp 8081/tcp 4001/tcp; do ufw allow "$p"; done
    info "UFW: stack ports opened."
else
    warn "UFW not found — skipping firewall rules."
fi

section "Step 9: Pulling a Starter Model (qwen2.5:0.5b, ~400 MB)"
sleep 5
if docker exec ai-ollama ollama pull qwen2.5:0.5b; then
    info "Starter model ready."
else
    warn "Model pull failed — run later: docker exec ai-ollama ollama pull qwen2.5:0.5b"
fi

section "Step 10: Health Check"
HEALTH_OK=0
for i in $(seq 1 24); do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://127.0.0.1:3210 2>/dev/null || echo "000")
    if [ "$STATUS" != "000" ]; then
        info "Open WebUI is responding (HTTP $STATUS). ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/24 — waiting 5s..."
    sleep 5
    echo " retrying"
done
[ "$HEALTH_OK" -eq 0 ] && warn "Open WebUI not responding yet. Check: docker logs ai-webui"

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║               ✅  AI STACK READY!                    ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  💬  Open WebUI:  http://$SERVER_IP:3210"
echo "  ║      First account created becomes admin."
echo "  ║      Web search is ON (via your private SearXNG)."
echo "  ║      Model 'qwen2.5:0.5b' is ready to chat."
echo "  ║"
echo "  ║  🦙  Ollama API:  http://$SERVER_IP:11434"
echo "  ║  🔍  SearXNG:     http://$SERVER_IP:8081"
echo "  ║  🔌  OpenAI-compatible API (LiteLLM):"
echo "  ║      http://$SERVER_IP:4001/v1   key: $LITELLM_KEY"
echo "  ║"
echo "  ║  💡  Bigger models: docker exec ai-ollama ollama pull llama3.2"
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
