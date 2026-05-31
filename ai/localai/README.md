# LocalAI — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

OpenAI-compatible self-hosted API for running LLMs, image generation, and audio models locally without a GPU requirement.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is LocalAI?

LocalAI is a drop-in replacement for the OpenAI API that runs entirely on your own hardware. It supports text generation (LLMs), image generation (Stable Diffusion), speech-to-text (Whisper), and text-to-speech — all without sending data to the cloud. Any OpenAI-compatible client or library can point to LocalAI with a simple URL change.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ai/localai/localai-ubuntu.sh
chmod +x localai-ubuntu.sh
sudo bash localai-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Starts the AIO CPU image
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI / API** | `http://SERVER_IP:8085` |
| **OpenAI-compatible endpoint** | `http://SERVER_IP:8085/v1` |
| **Username** | Not required |
| **Password** | Not required |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8085` | TCP | Web UI / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/localai/` | All service data and configuration |
| `/root/docker/localai/models/` | Downloaded model files |

---

## Management

```bash
# Follow logs
docker logs -f localai

# Stop
cd /root/docker/localai && docker compose down

# Start
cd /root/docker/localai && docker compose up -d

# Update to latest image
cd /root/docker/localai && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8085/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
