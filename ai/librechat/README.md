# LibreChat — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Unified AI chat interface supporting OpenAI, Claude, Gemini, Ollama, and 10+ providers in one self-hosted UI.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is LibreChat?

LibreChat is an open-source ChatGPT-like interface that aggregates multiple AI providers into a single platform. It supports OpenAI, Anthropic Claude, Google Gemini, Mistral, Groq, Ollama (local models), and many more. Features include conversation history stored locally in MongoDB, plugins, image generation, code interpreter, and multi-user support.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ai/librechat/librechat-ubuntu.sh
chmod +x librechat-ubuntu.sh
sudo bash librechat-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure JWT secrets
- Starts the service stack (LibreChat + MongoDB)
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:3080` |
| **Username** | Registered on first visit |
| **Password** | Registered on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3080` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/librechat/` | All service data and configuration |
| `/root/docker/librechat/data/mongodb/` | MongoDB database files |
| `/root/docker/librechat/uploads/` | Uploaded files |

---

## Management

```bash
# Follow logs
docker logs -f librechat

# Stop
cd /root/docker/librechat && docker compose down

# Start
cd /root/docker/librechat && docker compose up -d

# Update to latest image
cd /root/docker/librechat && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 3080/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
