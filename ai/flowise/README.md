# Flowise — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Open-source visual builder for LLM workflows, drag-and-drop chains, agents, and API endpoints powered by LangChain.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Flowise?

Flowise is a low-code platform for building LLM-powered applications using a visual node-based interface. You can construct chatbots, RAG pipelines, and autonomous agents by connecting components from LangChain and LlamaIndex. Each flow can be exposed as a REST API endpoint with a single click, supporting OpenAI, Ollama, HuggingFace, and many other integrations.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ai/flowise/flowise-ubuntu.sh
chmod +x flowise-ubuntu.sh
sudo bash flowise-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:3060` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3060` | TCP | Web UI / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/flowise/` | All service data and configuration |
| `/root/docker/flowise/data/` | Flows, credentials, and database |

---

## Management

```bash
# Follow logs
docker logs -f flowise

# Stop
cd /root/docker/flowise && docker compose down

# Start
cd /root/docker/flowise && docker compose up -d

# Update to latest image
cd /root/docker/flowise && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 3060/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
