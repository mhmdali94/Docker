#!/bin/bash
#
# ============================================================
#   Ollama Auto-Installer (+ optional Open WebUI)
#   Made by: Mohammed Ali Elshikh | prismatechwork.com
#
#   ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️
#   This script is NOT intended for production use.
# ============================================================

set -e

# ── Colors & helpers ─────────────────────────────────────────────────
G="\e[32m"; Y="\e[33m"; R="\e[31m"; C="\e[36m"; B="\e[1m"; RST="\e[0m"
info()    { echo -e "${G}[INFO]${RST} $*"; }
warn()    { echo -e "${Y}[WARN]${RST} $*"; }
error()   { echo -e "${R}[ERROR]${RST} $*"; exit 1; }
section() { echo -e "\n${C}${B}══════════════════════ $* ══════════════════════${RST}"; }

# ── Model registry ────────────────────────────────────────────────────
#   MODEL_DL   = download size (GB, approx)
#   MODEL_RAM  = minimum RAM for CPU inference (GB)
#   MODEL_VRAM = minimum VRAM for GPU inference (GB)
#   MODEL_SPEED= CPU inference speed rating
#   MODEL_CAT  = display category

declare -A MODEL_MAP MODEL_DL MODEL_RAM MODEL_VRAM MODEL_SPEED MODEL_CAT

MODEL_MAP[1]="llama3.2:3b"           MODEL_DL[1]=2   MODEL_RAM[1]=8   MODEL_VRAM[1]=3   MODEL_SPEED[1]="Fast"       MODEL_CAT[1]="General"
MODEL_MAP[2]="llama3.2:1b"           MODEL_DL[2]=1   MODEL_RAM[2]=4   MODEL_VRAM[2]=2   MODEL_SPEED[2]="Very Fast"  MODEL_CAT[2]="General"
MODEL_MAP[3]="mistral:7b"            MODEL_DL[3]=4   MODEL_RAM[3]=8   MODEL_VRAM[3]=6   MODEL_SPEED[3]="Medium"     MODEL_CAT[3]="General"
MODEL_MAP[4]="gemma3:4b"             MODEL_DL[4]=3   MODEL_RAM[4]=6   MODEL_VRAM[4]=4   MODEL_SPEED[4]="Fast"       MODEL_CAT[4]="General"
MODEL_MAP[5]="qwen2.5:7b"            MODEL_DL[5]=5   MODEL_RAM[5]=8   MODEL_VRAM[5]=6   MODEL_SPEED[5]="Medium"     MODEL_CAT[5]="General"
MODEL_MAP[6]="qwen2.5-coder:7b"      MODEL_DL[6]=5   MODEL_RAM[6]=8   MODEL_VRAM[6]=6   MODEL_SPEED[6]="Medium"     MODEL_CAT[6]="Coding"
MODEL_MAP[7]="qwen2.5-coder:14b"     MODEL_DL[7]=9   MODEL_RAM[7]=16  MODEL_VRAM[7]=10  MODEL_SPEED[7]="Slow"       MODEL_CAT[7]="Coding"
MODEL_MAP[8]="deepseek-coder-v2:16b" MODEL_DL[8]=10  MODEL_RAM[8]=20  MODEL_VRAM[8]=12  MODEL_SPEED[8]="Slow"       MODEL_CAT[8]="Coding"
MODEL_MAP[9]="codellama:7b"          MODEL_DL[9]=4   MODEL_RAM[9]=8   MODEL_VRAM[9]=6   MODEL_SPEED[9]="Medium"     MODEL_CAT[9]="Coding"
MODEL_MAP[10]="codellama:13b"        MODEL_DL[10]=8  MODEL_RAM[10]=16 MODEL_VRAM[10]=10 MODEL_SPEED[10]="Slow"      MODEL_CAT[10]="Coding"
MODEL_MAP[11]="codegemma:7b"         MODEL_DL[11]=5  MODEL_RAM[11]=8  MODEL_VRAM[11]=6  MODEL_SPEED[11]="Medium"    MODEL_CAT[11]="Coding"
MODEL_MAP[12]="starcoder2:7b"        MODEL_DL[12]=4  MODEL_RAM[12]=8  MODEL_VRAM[12]=6  MODEL_SPEED[12]="Medium"    MODEL_CAT[12]="Coding"
MODEL_MAP[13]="devstral:24b"         MODEL_DL[13]=15 MODEL_RAM[13]=32 MODEL_VRAM[13]=16 MODEL_SPEED[13]="Very Slow" MODEL_CAT[13]="Coding"
MODEL_MAP[14]="deepseek-r1:7b"       MODEL_DL[14]=5  MODEL_RAM[14]=8  MODEL_VRAM[14]=6  MODEL_SPEED[14]="Medium"    MODEL_CAT[14]="Reasoning"
MODEL_MAP[15]="deepseek-r1:14b"      MODEL_DL[15]=9  MODEL_RAM[15]=16 MODEL_VRAM[15]=10 MODEL_SPEED[15]="Slow"      MODEL_CAT[15]="Reasoning"
MODEL_MAP[16]="deepseek-r1:32b"      MODEL_DL[16]=20 MODEL_RAM[16]=40 MODEL_VRAM[16]=20 MODEL_SPEED[16]="Very Slow" MODEL_CAT[16]="Reasoning"
MODEL_MAP[17]="qwq:32b"              MODEL_DL[17]=20 MODEL_RAM[17]=40 MODEL_VRAM[17]=20 MODEL_SPEED[17]="Very Slow" MODEL_CAT[17]="Reasoning"
MODEL_MAP[18]="phi4:14b"             MODEL_DL[18]=9  MODEL_RAM[18]=16 MODEL_VRAM[18]=10 MODEL_SPEED[18]="Slow"      MODEL_CAT[18]="Reasoning"
MODEL_MAP[19]="aya-expanse:8b"       MODEL_DL[19]=5  MODEL_RAM[19]=10 MODEL_VRAM[19]=6  MODEL_SPEED[19]="Medium"    MODEL_CAT[19]="Multilingual"
MODEL_MAP[20]="qwen2.5:14b"          MODEL_DL[20]=9  MODEL_RAM[20]=16 MODEL_VRAM[20]=10 MODEL_SPEED[20]="Slow"      MODEL_CAT[20]="Multilingual"
MODEL_TOTAL=20

# ─────────────────────────────────────────────────────────────────────

clear
echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║     Ollama Auto-Installer                        ║"
echo "  ║     Made by: Mohammed Ali Elshikh               ║"
echo "  ║     prismatechwork.com                          ║"
echo "  ║                                                  ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️         ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║  This installer is intended for demo and testing.   ║"
echo "  ║  For a production-ready, hardened setup contact:    ║"
echo "  ║                                                      ║"
echo "  ║  👨‍💻  Mohammed Ali Elshikh  |  prismatechwork.com    ║"
echo "  ║                                                      ║"
echo "  ║  Press ENTER to continue ...  Ctrl+C to cancel.    ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
read -rp "" _DEMO_CONFIRM

# ─────────────────────────────────────────────────────────────────────

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

# ─────────────────────────────────────────────────────────────────────

section "Step 4: Your Hardware"
echo ""
echo "  What type of hardware is this server running?"
echo ""
echo "  [1]  CPU only       No GPU — works on any server, slower inference"
echo "  [2]  NVIDIA GPU     CUDA acceleration — fastest option"
echo "  [3]  AMD GPU        ROCm acceleration — experimental"
echo ""
read -rp "  Your hardware [1/2/3]: " HW_CHOICE

case "$HW_CHOICE" in
    2) USE_GPU=true;  GPU_TYPE="nvidia"; info "NVIDIA GPU selected." ;;
    3) USE_GPU=true;  GPU_TYPE="amd";    info "AMD GPU (ROCm) selected." ;;
    *) USE_GPU=false; GPU_TYPE="cpu";    info "CPU-only selected." ;;
esac

echo ""
if [ "$USE_GPU" = true ]; then
    echo "  How much VRAM does your GPU have?"
    echo ""
    echo "  [1]  4 GB   (GTX 1650, RX 570)"
    echo "  [2]  6 GB   (RTX 3060, RX 6600)"
    echo "  [3]  8 GB   (RTX 3070, RX 6700)"
    echo "  [4]  10 GB  (RTX 3080 10GB)"
    echo "  [5]  12 GB  (RTX 3060 Ti, RX 7700)"
    echo "  [6]  16 GB  (RTX 4080, RX 7900 GRE)"
    echo "  [7]  24 GB+ (RTX 3090, RTX 4090, A100)"
    echo ""
    read -rp "  Your VRAM [1-7]: " MEM_CHOICE
    case "$MEM_CHOICE" in
        1) USER_MEM=4  ;;
        2) USER_MEM=6  ;;
        3) USER_MEM=8  ;;
        4) USER_MEM=10 ;;
        5) USER_MEM=12 ;;
        6) USER_MEM=16 ;;
        7) USER_MEM=24 ;;
        *) USER_MEM=8  ;;
    esac
    info "GPU VRAM: ${USER_MEM} GB"
else
    echo "  How much RAM does your server have?"
    echo ""
    echo "  [1]  4 GB    (minimal — only tiny models)"
    echo "  [2]  8 GB    (entry — 7B models)"
    echo "  [3]  16 GB   (comfortable — up to 14B)"
    echo "  [4]  24 GB   (good — up to 16B)"
    echo "  [5]  32 GB   (large — up to 24B)"
    echo "  [6]  48 GB+  (high-end — 32B+ models)"
    echo ""
    read -rp "  Your RAM [1-6]: " MEM_CHOICE
    case "$MEM_CHOICE" in
        1) USER_MEM=4  ;;
        2) USER_MEM=8  ;;
        3) USER_MEM=16 ;;
        4) USER_MEM=24 ;;
        5) USER_MEM=32 ;;
        6) USER_MEM=48 ;;
        *) USER_MEM=8  ;;
    esac
    info "Server RAM: ${USER_MEM} GB"
fi

# ─────────────────────────────────────────────────────────────────────

section "Step 5: Installation Type"
echo ""
echo "  What do you want to install?"
echo ""
echo "  [1]  Ollama + Open WebUI   Chat interface included   ~4 GB Docker images"
echo "  [2]  Ollama only           API server only           ~1.5 GB Docker image"
echo ""
read -rp "  Your choice [1/2]: " INSTALL_CHOICE
case "$INSTALL_CHOICE" in
    2) INSTALL_WEBUI=false; info "Ollama only selected." ;;
    *) INSTALL_WEBUI=true;  info "Ollama + Open WebUI selected." ;;
esac

# ─────────────────────────────────────────────────────────────────────

section "Step 6: Model Selection"
echo ""

if [ "$USE_GPU" = true ]; then
    echo -e "  ${B}Hardware: ${GPU_TYPE^^} GPU — ${USER_MEM} GB VRAM${RST}"
    echo -e "  ${G}✅ OK${RST} = fits in your VRAM   ${R}❌ Need X GB${RST} = exceeds your VRAM"
    echo ""
    printf "  ${B}%-5s %-28s %-8s %-11s %s${RST}\n" "Num" "Model" "DL" "Min VRAM" "Status"
    echo "  ─────────────────────────────────────────────────────────────────"
else
    echo -e "  ${B}Hardware: CPU only — ${USER_MEM} GB RAM${RST}"
    echo -e "  ${G}✅ OK${RST} = fits your RAM   ${Y}⚠️  Needs X GB${RST} = will use swap (slow)   ${R}❌${RST} = GPU only limit"
    echo ""
    printf "  ${B}%-5s %-28s %-8s %-9s %-13s %s${RST}\n" "Num" "Model" "DL" "Min RAM" "CPU Speed" "Status"
    echo "  ─────────────────────────────────────────────────────────────────────────"
fi

PREV_CAT=""
for i in $(seq 1 $MODEL_TOTAL); do
    CAT="${MODEL_CAT[$i]}"
    if [ "$CAT" != "$PREV_CAT" ]; then
        echo ""
        echo -e "  ${C}── ${CAT} ──${RST}"
        PREV_CAT="$CAT"
    fi

    if [ "$USE_GPU" = true ]; then
        REQ="${MODEL_VRAM[$i]}"
    else
        REQ="${MODEL_RAM[$i]}"
    fi

    if [ "$USER_MEM" -ge "$REQ" ]; then
        STATUS="${G}✅ OK${RST}"
    elif [ "$USE_GPU" = true ]; then
        STATUS="${R}❌ Need ${REQ} GB VRAM${RST}"
    else
        STATUS="${Y}⚠️  Needs ${REQ} GB RAM (will use swap — very slow)${RST}"
    fi

    if [ "$USE_GPU" = true ]; then
        printf "  %-5s %-28s %-8s %-11s " \
            "[${i}]" "${MODEL_MAP[$i]}" "~${MODEL_DL[$i]} GB" "${REQ} GB"
    else
        printf "  %-5s %-28s %-8s %-9s %-13s " \
            "[${i}]" "${MODEL_MAP[$i]}" "~${MODEL_DL[$i]} GB" "${REQ} GB" "${MODEL_SPEED[$i]}"
    fi
    echo -e "$STATUS"
done

echo ""
echo "  [0]  Skip — pull models manually later"
echo ""
read -rp "  Your selection (e.g. 1 6 14): " MODEL_SELECTION

# Warn CPU users who selected models that exceed their RAM
if [ "$USE_GPU" = false ] && [ "$MODEL_SELECTION" != "0" ] && [ -n "$MODEL_SELECTION" ]; then
    OVER_SPEC=()
    for num in $MODEL_SELECTION; do
        if [ -n "${MODEL_MAP[$num]}" ] && [ "${MODEL_RAM[$num]}" -gt "$USER_MEM" ]; then
            OVER_SPEC+=("$num")
        fi
    done

    if [ "${#OVER_SPEC[@]}" -gt 0 ]; then
        echo ""
        echo -e "  ${Y}╔══════════════════════════════════════════════════════════════╗${RST}"
        echo -e "  ${Y}║  ⚠️   CAUTION — Models exceed your available RAM             ║${RST}"
        echo -e "  ${Y}╠══════════════════════════════════════════════════════════════╣${RST}"
        echo -e "  ${Y}║                                                              ║${RST}"
        for num in "${OVER_SPEC[@]}"; do
            DEFICIT=$((MODEL_RAM[$num] - USER_MEM))
            printf "  ${Y}║${RST}  %-28s needs %2s GB — you have %2s GB  ${Y}║${RST}\n" \
                "${MODEL_MAP[$num]}" "${MODEL_RAM[$num]}" "${USER_MEM}"
        done
        echo -e "  ${Y}║                                                              ║${RST}"
        echo -e "  ${Y}║  These models WILL run but will spill into disk swap.        ║${RST}"
        echo -e "  ${Y}║  Expect:                                                     ║${RST}"
        echo -e "  ${Y}║    • Very slow responses (minutes per reply)                 ║${RST}"
        echo -e "  ${Y}║    • High disk I/O — SSD strongly recommended                ║${RST}"
        echo -e "  ${Y}║    • Risk of OOM crash on severely under-spec servers        ║${RST}"
        echo -e "  ${Y}║                                                              ║${RST}"
        echo -e "  ${Y}╚══════════════════════════════════════════════════════════════╝${RST}"
        echo ""
        read -rp "  Install these models anyway? [y/N]: " _OVER_CONFIRM
        case "$_OVER_CONFIRM" in
            [yY][eE][sS]|[yY]) warn "Proceeding with over-spec models. You have been warned." ;;
            *)
                # Remove over-spec models from selection
                NEW_SELECTION=""
                for num in $MODEL_SELECTION; do
                    KEEP=true
                    for over in "${OVER_SPEC[@]}"; do
                        [ "$num" = "$over" ] && KEEP=false && break
                    done
                    [ "$KEEP" = true ] && NEW_SELECTION="$NEW_SELECTION $num"
                done
                MODEL_SELECTION="${NEW_SELECTION# }"
                info "Over-spec models removed. Continuing with: ${MODEL_SELECTION:-none}"
                ;;
        esac
    fi
fi

# ─────────────────────────────────────────────────────────────────────

section "Step 7: Download Summary"
echo ""
echo -e "  ${B}Everything that will be downloaded and installed:${RST}"
echo ""

# Calculate total space needed
if [ "$GPU_TYPE" = "amd" ]; then
    SPACE_NEEDED=3
else
    SPACE_NEEDED=2
fi
[ "$INSTALL_WEBUI" = true ] && SPACE_NEEDED=$((SPACE_NEEDED + 3))

if [ "$USE_GPU" = true ]; then
    if [ "$GPU_TYPE" = "amd" ]; then
        echo "  Docker image:   ollama/ollama:rocm              ~3 GB"
    else
        echo "  Docker image:   ollama/ollama:latest            ~1.5 GB"
    fi
else
    echo "  Docker image:   ollama/ollama:latest            ~1.5 GB"
fi
[ "$INSTALL_WEBUI" = true ] && echo "  Docker image:   open-webui/open-webui:main      ~2.5 GB"

if [ "$MODEL_SELECTION" != "0" ] && [ -n "$MODEL_SELECTION" ]; then
    echo ""
    echo "  Models:"
    for num in $MODEL_SELECTION; do
        MODEL="${MODEL_MAP[$num]}"
        if [ -n "$MODEL" ]; then
            printf "    • %-30s ~%s GB\n" "$MODEL" "${MODEL_DL[$num]}"
            SPACE_NEEDED=$((SPACE_NEEDED + MODEL_DL[$num]))
        fi
    done
fi

# Add 20% buffer to space estimate
SPACE_NEEDED=$((SPACE_NEEDED + SPACE_NEEDED / 5))

# Check available disk space on Docker's storage path
DOCKER_DIR="/var/lib/docker"
[ ! -d "$DOCKER_DIR" ] && DOCKER_DIR="/"
AVAIL_SPACE=$(df -BG "$DOCKER_DIR" 2>/dev/null | awk 'NR==2 {gsub(/G/,"",$4); print int($4)}')

echo ""
echo "  ┌──────────────────────────────────────────────────────┐"
printf "  │  Space required  (with 20%% buffer): %-14s │\n" "~${SPACE_NEEDED} GB"
printf "  │  Space available (on %-16s): %-14s │\n" "$DOCKER_DIR" "${AVAIL_SPACE} GB"
if [ "$AVAIL_SPACE" -lt "$SPACE_NEEDED" ]; then
    NEED_MORE=$((SPACE_NEEDED - AVAIL_SPACE))
    echo "  │                                                      │"
    printf "  │  ${R}❌ Not enough space — free up ~%s GB first.${RST}%-6s│\n" "$NEED_MORE" " "
    echo "  └──────────────────────────────────────────────────────┘"
    echo ""
    read -rp "  Continue anyway? [y/N]: " _SPACE_CONFIRM
    case "$_SPACE_CONFIRM" in
        [yY][eE][sS]|[yY]) warn "Continuing despite low disk space..." ;;
        *) info "Aborted. Free up disk space and run again."; exit 0 ;;
    esac
else
    echo -e "  │  ${G}✅ Enough disk space.${RST}                                │"
    echo "  └──────────────────────────────────────────────────────┘"
fi

echo ""
read -rp "  Do you want to continue? [y/N]: " _CONFIRM
case "$_CONFIRM" in
    [yY][eE][sS]|[yY]) ;;
    *) info "Aborted. Run again when ready."; exit 0 ;;
esac

# ─────────────────────────────────────────────────────────────────────
# From here: all downloads and installation
# ─────────────────────────────────────────────────────────────────────

section "Step 8: Cleaning Up Existing Containers"
for cname in ollama open-webui; do
    EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E "^${cname}$" || true)
    if [ -n "$EXISTING" ]; then
        warn "Removing existing container: $cname"
        docker rm -f "$cname" 2>/dev/null || true
    fi
done
docker network prune -f &>/dev/null || true

section "Step 9: Preparing Directory"
OLLAMA_DIR="/root/docker/ollama"
if [ -d "$OLLAMA_DIR" ]; then
    warn "Removing old directory $OLLAMA_DIR..."
    rm -rf "$OLLAMA_DIR"
fi
mkdir -p "$OLLAMA_DIR"
cd "$OLLAMA_DIR" || error "Cannot navigate to $OLLAMA_DIR"
info "Directory ready: $OLLAMA_DIR"

section "Step 10: Writing docker-compose.yml"

# Build the Ollama service block based on GPU type
if [ "$GPU_TYPE" = "nvidia" ]; then
    OLLAMA_IMAGE="ollama/ollama:latest"
    OLLAMA_EXTRA=$(cat <<'NVIDIA'
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
NVIDIA
)
elif [ "$GPU_TYPE" = "amd" ]; then
    OLLAMA_IMAGE="ollama/ollama:rocm"
    OLLAMA_EXTRA=$(cat <<'AMD'
    devices:
      - /dev/kfd
      - /dev/dri
AMD
)
else
    OLLAMA_IMAGE="ollama/ollama:latest"
    OLLAMA_EXTRA=""
fi

if [ "$INSTALL_WEBUI" = true ]; then
    cat > "$OLLAMA_DIR/docker-compose.yml" <<EOF
services:
  ollama:
    image: ${OLLAMA_IMAGE}
    container_name: ollama
    restart: unless-stopped
    ports:
      - "11434:11434"
    environment:
      OLLAMA_HOST: 0.0.0.0
    volumes:
      - ./ollama:/root/.ollama
${OLLAMA_EXTRA}

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
else
    cat > "$OLLAMA_DIR/docker-compose.yml" <<EOF
services:
  ollama:
    image: ${OLLAMA_IMAGE}
    container_name: ollama
    restart: unless-stopped
    ports:
      - "11434:11434"
    environment:
      OLLAMA_HOST: 0.0.0.0
    volumes:
      - ./ollama:/root/.ollama
${OLLAMA_EXTRA}
EOF
fi
info "docker-compose.yml created."

section "Step 11: GPU Toolkit Check"
if [ "$GPU_TYPE" = "nvidia" ]; then
    if ! dpkg -l 2>/dev/null | grep -q "nvidia-container-toolkit"; then
        warn "NVIDIA Container Toolkit not found — required for GPU acceleration."
        echo ""
        read -rp "  Install NVIDIA Container Toolkit now? [y/N]: " _NVIDIA_INSTALL
        case "$_NVIDIA_INSTALL" in
            [yY][eE][sS]|[yY])
                info "Installing NVIDIA Container Toolkit..."
                curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
                    | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
                curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
                    | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
                    | tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
                apt update -y && apt install -y nvidia-container-toolkit
                nvidia-ctk runtime configure --runtime=docker
                systemctl restart docker
                info "NVIDIA Container Toolkit installed. ✅"
                ;;
            *)
                warn "Skipped. GPU passthrough will not work without it."
                warn "Install later: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html"
                ;;
        esac
    else
        info "NVIDIA Container Toolkit found. ✅"
    fi
elif [ "$GPU_TYPE" = "amd" ]; then
    if [ ! -e /dev/kfd ]; then
        warn "/dev/kfd not found — ROCm driver may not be installed."
        warn "Install ROCm: https://rocm.docs.amd.com/en/latest/deploy/linux/quick_start.html"
    else
        info "AMD ROCm device /dev/kfd found. ✅"
    fi
else
    info "CPU mode — no GPU toolkit needed."
fi

section "Step 12: Starting Containers"
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    if docker compose version &> /dev/null; then
        docker compose up -d && break
    else
        docker-compose up -d && break
    fi
    warn "Docker pull failed on attempt $attempt/$MAX_RETRIES."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed after $MAX_RETRIES attempts. Run: cd $OLLAMA_DIR && docker compose up -d"
done

section "Step 13: Verifying Containers"
sleep 8
VERIFY_LIST="ollama"
[ "$INSTALL_WEBUI" = true ] && VERIFY_LIST="ollama open-webui"
for cname in $VERIFY_LIST; do
    RUNNING=$(docker ps --format '{{.Names}}' | grep -E "^${cname}$" || true)
    if [ -z "$RUNNING" ]; then
        warn "Container '$cname' may not have started. Check: docker logs $cname"
    else
        info "Container running: $cname ✅"
    fi
done

if [ "$INSTALL_WEBUI" = true ]; then
    section "Step 14: Health Check (Open WebUI)"
    info "Waiting for Open WebUI on port 3210..."
    HEALTH_OK=0
    for i in $(seq 1 12); do
        if curl -sf --max-time 3 http://127.0.0.1:3210 &>/dev/null; then
            info "Open WebUI is healthy on port 3210. ✅"
            HEALTH_OK=1
            break
        fi
        echo -n "  Attempt $i/12 — waiting 5s..."
        sleep 5
        echo " retrying"
    done
    [ "$HEALTH_OK" -eq 0 ] && warn "Open WebUI may still be starting. Check: docker logs open-webui"
fi

section "Step 15: Swap & Memory Preparation"

# ── Swap setup ────────────────────────────────────────────────────────
# Ollama calculates available memory as MemFree + Buffers (not MemAvailable).
# On servers with little free RAM but lots of page cache, Ollama will refuse
# to load models even when Linux reports plenty of available memory.
# Swap gives Ollama the headroom it needs and prevents OOM on tight servers.

SWAP_TOTAL=$(free -m | awk '/Swap/ {print $2}')
if [ "$SWAP_TOTAL" -gt 0 ]; then
    info "Swap already configured: ${SWAP_TOTAL} MB — skipping swap setup."
else
    warn "No swap detected. Ollama may fail to load models without swap."
    echo ""
    echo "  Recommended: 8 GB swapfile (matches your RAM size)"
    echo "  This is written to /swapfile and persists across reboots."
    echo ""
    read -rp "  Set up 8 GB swap now? [Y/n]: " _SWAP_CONFIRM
    case "$_SWAP_CONFIRM" in
        [nN][oO]|[nN])
            warn "Swap skipped. If Ollama fails to load a model, run:"
            warn "  fallocate -l 8G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile"
            ;;
        *)
            if [ -f /swapfile ]; then
                warn "/swapfile already exists — reusing it."
                swapon /swapfile 2>/dev/null || true
            else
                info "Creating 8 GB swapfile..."
                fallocate -l 8G /swapfile
                chmod 600 /swapfile
                mkswap /swapfile
                swapon /swapfile
                # Persist across reboots
                if ! grep -q '/swapfile' /etc/fstab; then
                    echo '/swapfile none swap sw 0 0' >> /etc/fstab
                fi
            fi
            SWAP_NOW=$(free -m | awk '/Swap/ {print $2}')
            info "Swap active: ${SWAP_NOW} MB ✅"
            ;;
    esac
fi

# ── Drop page cache ───────────────────────────────────────────────────
# Force Linux to release cached pages so MemFree jumps up.
# Ollama reads MemFree + Buffers — not the higher MemAvailable figure.
MEM_BEFORE=$(awk '/MemFree/ {printf "%d", $2/1024}' /proc/meminfo)
sync && echo 3 > /proc/sys/vm/drop_caches
MEM_AFTER=$(awk '/MemFree/ {printf "%d", $2/1024}' /proc/meminfo)
info "Page cache cleared: ${MEM_BEFORE} MB → ${MEM_AFTER} MB free ✅"

section "Step 16: Pulling Models"
PULLED_MODELS=()
if [ "$MODEL_SELECTION" != "0" ] && [ -n "$MODEL_SELECTION" ]; then
    info "Waiting for Ollama API..."
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
            info "Pulling $MODEL (~${MODEL_DL[$num]} GB) — this may take several minutes..."
            if docker exec ollama ollama pull "$MODEL"; then
                info "$MODEL pulled successfully. ✅"
                PULLED_MODELS+=("$MODEL")
            else
                warn "Failed to pull $MODEL. Pull later: docker exec ollama ollama pull $MODEL"
            fi
        else
            warn "Unknown selection: $num — skipped."
        fi
    done
else
    info "Skipping model pull. Pull models later:"
    info "  docker exec ollama ollama pull <model-name>"
fi

section "Step 17: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    ufw allow 11434/tcp
    [ "$INSTALL_WEBUI" = true ] && ufw allow 3210/tcp
    info "UFW ports opened."
else
    warn "UFW not found — skipping firewall rules."
fi

# ── Summary ───────────────────────────────────────────────────────────
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║              ✅  Setup Complete!                     ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
if [ "$INSTALL_WEBUI" = true ]; then
echo "  ║  🌐  Open WebUI:                                   ║"
echo "  ║      👉  http://$SERVER_IP:3210"
echo "  ║                                                      ║"
fi
echo "  ║  🤖  Ollama API:                                   ║"
echo "  ║      👉  http://$SERVER_IP:11434"
echo "  ║                                                      ║"
if [ "$USE_GPU" = true ]; then
echo "  ║  ⚡  GPU:  ${GPU_TYPE^^} acceleration enabled              ║"
echo "  ║                                                      ║"
fi
if [ "${#PULLED_MODELS[@]}" -gt 0 ]; then
    echo "  ║  📦  Models installed:                             ║"
    for m in "${PULLED_MODELS[@]}"; do
        printf "  ║      ✅  %-42s ║\n" "$m"
    done
    echo "  ║                                                      ║"
else
    echo "  ║  📦  Pull a model:                                 ║"
    echo "  ║      docker exec ollama ollama pull llama3.2:3b    ║"
    echo "  ║                                                      ║"
fi
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️            ║"
echo "  ║       Made by: Mohammed Ali Elshikh                 ║"
echo "  ║       prismatechwork.com                            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║  🚀  Need a production-ready setup?                 ║"
echo "  ║  Contact: Mohammed Ali Elshikh | prismatechwork.com ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
