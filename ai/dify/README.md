# Dify — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Visual LLM application builder with RAG pipelines, agent workflows, and multi-model support for building AI-powered products.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Dify?

Dify is an open-source LLM application development platform that lets you visually build AI workflows, RAG pipelines, and chatbot agents without deep coding. It supports OpenAI, Anthropic, Ollama, Azure, and many other model providers. Features include prompt orchestration, knowledge bases, tool integrations, and a built-in API layer.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ai/dify/dify-ubuntu.sh
chmod +x dify-ubuntu.sh
sudo bash dify-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure credentials and secrets
- Starts the full stack (nginx, API, worker, web, sandbox, PostgreSQL, Redis)
- Runs database migrations and a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:3050` |
| **Username** | Created on first visit (setup wizard) |
| **Password** | Created on first visit (setup wizard) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3050` | TCP | Web UI / API (via nginx) |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/dify/` | All service data and configuration |
| `/root/docker/dify/storage/` | Uploaded files and assets |

---

## Management

```bash
# Follow logs
docker logs -f dify-api

# Stop
cd /root/docker/dify && docker compose down

# Start
cd /root/docker/dify && docker compose up -d

# Update to latest image
cd /root/docker/dify && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 3050/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
