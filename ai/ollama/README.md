# Ollama — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Run AI language models entirely on your own server with no cloud dependency, no API keys, and no usage fees.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Ollama?

Ollama is a runtime engine for running large language models locally on your own hardware. It supports CPU, NVIDIA GPU (CUDA), and AMD GPU (ROCm), and exposes an OpenAI-compatible API. The installer includes optional Open WebUI for a browser-based chat interface, interactive model selection with RAM/VRAM compatibility checks, and automatic disk space verification before downloading.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ai/ollama/ollama-ubuntu.sh
chmod +x ollama-ubuntu.sh
sudo bash ollama-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for hardware type (CPU, NVIDIA GPU, AMD GPU) and available memory
- Optionally installs Open WebUI alongside Ollama
- Presents a model selection menu with 20 curated models
- Pulls selected models and configures swap if needed
- Runs a health check

---

## Access

| | |
|---|---|
| **Ollama API** | `http://SERVER_IP:11434` |
| **Open WebUI** (if installed) | `http://SERVER_IP:3210` |
| **Open WebUI Username** | Created on first visit |
| **Open WebUI Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `11434` | TCP | Ollama API |
| `3210` | TCP | Open WebUI (if installed) |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/ollama/` | All service data and configuration |
| `/root/docker/ollama/ollama/` | Downloaded model files |
| `/root/docker/ollama/webui/` | Open WebUI data (if installed) |

---

## Management

```bash
# Follow logs
docker logs -f ollama

# Pull a model
docker exec ollama ollama pull llama3.2:3b

# List installed models
docker exec ollama ollama list

# Stop
cd /root/docker/ollama && docker compose down

# Start
cd /root/docker/ollama && docker compose up -d

# Update to latest image
cd /root/docker/ollama && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 11434/tcp open in firewall
- Port 3210/tcp open in firewall (if Open WebUI is installed)
- (Optional) NVIDIA GPU with nvidia-container-toolkit, or AMD GPU with ROCm

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
