# ComfyUI — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Stable Diffusion image generation with a powerful node-based workflow interface — generate AI images locally with no cloud dependency.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is ComfyUI?

ComfyUI is a modular, node-based interface for Stable Diffusion and other diffusion models. It provides granular control over the entire generation pipeline, supports SDXL, SD 1.5, Flux, ControlNet, IP-Adapter, and most community models. Workflows are saved as JSON and can be shared and reused. Supports NVIDIA GPU acceleration or CPU-only mode.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ai/comfyui/comfyui-ubuntu.sh
chmod +x comfyui-ubuntu.sh
sudo bash comfyui-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for GPU (NVIDIA) or CPU-only mode
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:8188` |
| **Username** | Not required |
| **Password** | Not required |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8188` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/comfyui/` | All service data and configuration |
| `/root/docker/comfyui/models/` | AI model files |
| `/root/docker/comfyui/output/` | Generated images |

---

## Management

```bash
# Follow logs
docker logs -f comfyui

# Stop
cd /root/docker/comfyui && docker compose down

# Start
cd /root/docker/comfyui && docker compose up -d

# Update to latest image
cd /root/docker/comfyui && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8188/tcp open in firewall
- (Optional) NVIDIA GPU with nvidia-container-toolkit for hardware acceleration

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
