#!/bin/bash
#
# ============================================================
#   Ollama + Open WebUI Auto-Installer
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
echo "  ║     Ollama + Open WebUI Auto-Installer           ║"
echo "  ║     Made by: Mohammed Ali Elshikh               ║"
echo "  ║     prismatechwork.com                          ║"
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
for cname in ollama open-webui; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    if [ -n "$EXISTING" ]; then
        warn "Removing existing container: $cname"
        docker rm -f "$cname" 2>/dev/null || true
    fi
done
docker network prune -f &>/dev/null || true

section "Step 5: Preparing Directory"
OLLAMA_DIR="/root/docker/ollama"
if [ -d "$OLLAMA_DIR" ]; then
    warn "Removing old directory $OLLAMA_DIR..."
    rm -rf "$OLLAMA_DIR"
fi
mkdir -p "$OLLAMA_DIR"
cd "$OLLAMA_DIR" || error "Cannot navigate to $OLLAMA_DIR"
info "Directory ready: $OLLAMA_DIR"

section "Step 6: Writing docker-compose.yml"
cat > "$OLLAMA_DIR/docker-compose.yml" <<'EOF'
services:
  ollama:
    image: ollama/ollama:latest
    container_name: ollama
    restart: unless-stopped
    ports:
      - "11434:11434"
    volumes:
      - ./ollama:/root/.ollama

  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: open-webui
    restart: unless-stopped
    ports:
      - "3210:8080"
    environment:
      OLLAMA_BASE_URL: http://ollama:11434
    volumes:
      - ./webui:/app/backend/data
    depends_on:
      - ollama
EOF
info "docker-compose.yml created."

section "Step 7: Starting Ollama + Open WebUI"
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    if docker compose version &> /dev/null; then
        docker compose up -d && break
    else
        docker-compose up -d && break
    fi
    warn "Docker pull failed on attempt $attempt/$MAX_RETRIES (registry may be temporarily unavailable)."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed to start containers after $MAX_RETRIES attempts. Run manually: cd $OLLAMA_DIR && docker compose up -d"
done

section "Step 8: Verifying Containers"
sleep 8
for cname in ollama open-webui; do
    RUNNING=$(docker ps --format '{{.Names}}' | grep -E "^${cname}$" || true)
    if [ -z "$RUNNING" ]; then
        warn "Container '$cname' may not have started. Check: docker logs $cname"
    else
        info "Container running: $cname"
    fi
done

section "Step 9: Health Check"
info "Waiting for Open WebUI to be ready on port 3210..."
HEALTH_OK=0
for i in $(seq 1 12); do
    if curl -sf --max-time 3 http://127.0.0.1:3210 &>/dev/null; then
        info "Port 3210 is responding — Open WebUI is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    warn "Open WebUI may still be starting. Check: docker logs open-webui"
fi

section "Step 10: Model Selection"
echo ""
echo "  ┌──────────────────────────────────────────────────────────────────┐"
echo "  │  Select models to pull.                                          │"
echo "  │  Enter numbers separated by spaces.  Example:  1 6 12           │"
echo "  │  Models are downloaded from ollama.com — ensure internet access. │"
echo "  ├──────────────────────────────────────────────────────────────────┤"
echo "  │                                                                  │"
echo "  │  ── General Purpose ──────────────────────────────────────────  │"
echo "  │  [1]  llama3.2:3b           Fast, general chat         ~2 GB    │"
echo "  │  [2]  llama3.2:1b           Very fast, lightweight     ~1 GB    │"
echo "  │  [3]  mistral:7b            Strong reasoning           ~4 GB    │"
echo "  │  [4]  gemma3:4b             Google Gemma 3, efficient  ~3 GB    │"
echo "  │  [5]  qwen2.5:7b            Multilingual + Arabic      ~5 GB    │"
echo "  │                                                                  │"
echo "  │  ── Coding ───────────────────────────────────────────────────  │"
echo "  │  [6]  qwen2.5-coder:7b      Best mid-size coder        ~5 GB    │"
echo "  │  [7]  qwen2.5-coder:14b     Larger, stronger coder     ~9 GB    │"
echo "  │  [8]  deepseek-coder-v2:16b Top overall coding model   ~10 GB   │"
echo "  │  [9]  codellama:7b          Meta Code Llama 7B         ~4 GB    │"
echo "  │  [10] codellama:13b         Meta Code Llama 13B        ~8 GB    │"
echo "  │  [11] codegemma:7b          Google code model          ~5 GB    │"
echo "  │  [12] starcoder2:7b         StarCoder2, multi-language ~4 GB    │"
echo "  │  [13] devstral:24b          Mistral DevStral (agentic) ~15 GB   │"
echo "  │                                                                  │"
echo "  │  ── Reasoning / Math ─────────────────────────────────────────  │"
echo "  │  [14] deepseek-r1:7b        Chain-of-thought reasoning ~5 GB    │"
echo "  │  [15] deepseek-r1:14b       Strong reasoning + code    ~9 GB    │"
echo "  │  [16] deepseek-r1:32b       Best open reasoning model  ~20 GB   │"
echo "  │  [17] qwq:32b               Qwen QwQ reasoning         ~20 GB   │"
echo "  │  [18] phi4:14b              Microsoft Phi-4 reasoning  ~9 GB    │"
echo "  │                                                                  │"
echo "  │  ── Multilingual (Arabic support) ────────────────────────────  │"
echo "  │  [19] aya-expanse:8b        Cohere Aya, 23 languages   ~5 GB    │"
echo "  │  [20] qwen2.5:14b           Strong Arabic + reasoning  ~9 GB    │"
echo "  │                                                                  │"
echo "  │  [0]  Skip — I will pull models manually later                  │"
echo "  └──────────────────────────────────────────────────────────────────┘"
echo ""
read -rp "  Your selection: " MODEL_SELECTION

declare -A MODEL_MAP
MODEL_MAP[1]="llama3.2:3b"
MODEL_MAP[2]="llama3.2:1b"
MODEL_MAP[3]="mistral:7b"
MODEL_MAP[4]="gemma3:4b"
MODEL_MAP[5]="qwen2.5:7b"
MODEL_MAP[6]="qwen2.5-coder:7b"
MODEL_MAP[7]="qwen2.5-coder:14b"
MODEL_MAP[8]="deepseek-coder-v2:16b"
MODEL_MAP[9]="codellama:7b"
MODEL_MAP[10]="codellama:13b"
MODEL_MAP[11]="codegemma:7b"
MODEL_MAP[12]="starcoder2:7b"
MODEL_MAP[13]="devstral:24b"
MODEL_MAP[14]="deepseek-r1:7b"
MODEL_MAP[15]="deepseek-r1:14b"
MODEL_MAP[16]="deepseek-r1:32b"
MODEL_MAP[17]="qwq:32b"
MODEL_MAP[18]="phi4:14b"
MODEL_MAP[19]="aya-expanse:8b"
MODEL_MAP[20]="qwen2.5:14b"

PULLED_MODELS=()

if [ "$MODEL_SELECTION" != "0" ] && [ -n "$MODEL_SELECTION" ]; then
    info "Waiting for Ollama API to be ready..."
    for i in $(seq 1 30); do
        if curl -sf --max-time 3 http://127.0.0.1:11434 &>/dev/null; then
            info "Ollama API is ready."
            break
        fi
        sleep 2
    done

    for num in $MODEL_SELECTION; do
        MODEL="${MODEL_MAP[$num]}"
        if [ -n "$MODEL" ]; then
            info "Pulling $MODEL — this may take several minutes..."
            if docker exec ollama ollama pull "$MODEL"; then
                info "$MODEL pulled successfully. ✅"
                PULLED_MODELS+=("$MODEL")
            else
                warn "Failed to pull $MODEL. Pull it later: docker exec ollama ollama pull $MODEL"
            fi
        else
            warn "Unknown selection: $num — skipped."
        fi
    done
else
    info "Skipping model pull. Pull models later:"
    info "  docker exec ollama ollama pull <model-name>"
fi

section "Step 11: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    ufw allow 11434/tcp
    ufw allow 3210/tcp
    info "UFW: ports 11434/tcp and 3210/tcp opened."
else
    warn "UFW not found — skipping firewall rules."
fi

SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
echo "  ║  🌐  Open WebUI (chat interface):                  ║"
echo "  ║      👉  http://$SERVER_IP:3210"
echo "  ║                                                      ║"
echo "  ║  🤖  Ollama API:                                   ║"
echo "  ║      👉  http://$SERVER_IP:11434"
echo "  ║                                                      ║"

if [ "${#PULLED_MODELS[@]}" -gt 0 ]; then
    echo "  ║  📦  Models pulled:                                ║"
    for m in "${PULLED_MODELS[@]}"; do
        printf "  ║      ✅  %-42s ║\n" "$m"
    done
    echo "  ║                                                      ║"
else
    echo "  ║  📦  Pull a model:                                 ║"
    echo "  ║      docker exec ollama ollama pull llama3.2:3b     ║"
    echo "  ║      docker exec ollama ollama pull qwen2.5-coder:7b║"
    echo "  ║                                                      ║"
fi

echo "  ║  💡  Coding model recommendation:                  ║"
echo "  ║      qwen2.5-coder:7b  — best mid-size coder       ║"
echo "  ║      deepseek-coder-v2:16b — strongest coder       ║"
echo "  ║                                                      ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
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
