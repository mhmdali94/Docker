# AnythingLLM — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

An all-in-one AI application that lets you chat with any document or LLM, with built-in vector storage and multi-user workspace support.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is AnythingLLM?

AnythingLLM is a full-stack AI application for chatting with your documents using Retrieval-Augmented Generation (RAG). It connects to Ollama, OpenAI, Anthropic, Azure, and many other LLM providers. Features include multi-user workspaces, document management, chat history, and a REST API for integrations.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ai/anythingllm/anythingllm-ubuntu.sh
chmod +x anythingllm-ubuntu.sh
sudo bash anythingllm-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure JWT credentials
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:3030` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3030` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/anythingllm/` | All service data and configuration |
| `/root/docker/anythingllm/storage/` | Document storage and vector embeddings |

---

## Management

```bash
# Follow logs
docker logs -f anythingllm

# Stop
cd /root/docker/anythingllm && docker compose down

# Start
cd /root/docker/anythingllm && docker compose up -d

# Update to latest image
cd /root/docker/anythingllm && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 3030/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
