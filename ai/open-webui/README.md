# Open WebUI — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Self-hosted ChatGPT-style interface for running LLMs locally via Ollama or any OpenAI-compatible API.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Open WebUI?

Open WebUI is a feature-rich, extensible web interface for interacting with local LLMs. It provides a familiar chat experience with conversation history, model switching, system prompts, RAG document chat, and multi-user support. It connects to Ollama running on the same server or any OpenAI-compatible endpoint.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ai/open-webui/open-webui-ubuntu.sh
chmod +x open-webui-ubuntu.sh
sudo bash open-webui-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates a secure secret key
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:3000` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3000` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/open-webui/` | All service data and configuration |
| `/root/docker/open-webui/data/` | User data, history, and settings |

---

## Management

```bash
# Follow logs
docker logs -f open-webui

# Stop
cd /root/docker/open-webui && docker compose down

# Start
cd /root/docker/open-webui && docker compose up -d

# Update to latest image
cd /root/docker/open-webui && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 3000/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
