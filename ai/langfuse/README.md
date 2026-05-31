# Langfuse — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Open-source LLM observability platform for tracing, monitoring, evaluating, and debugging AI applications.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Langfuse?

Langfuse is an open-source LLM engineering platform that provides full observability into your AI applications. It captures traces, spans, and generations; supports evaluation workflows; tracks prompt versions; and provides cost and latency analytics across model providers. Integrates with LangChain, LlamaIndex, OpenAI SDK, and custom instrumentation via its API.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ai/langfuse/langfuse-ubuntu.sh
chmod +x langfuse-ubuntu.sh
sudo bash langfuse-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure credentials, encryption key, and salt
- Starts the service stack (Langfuse + PostgreSQL)
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:3006` |
| **Username** | Registered on first visit |
| **Password** | Registered on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3006` | TCP | Web UI / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/langfuse/` | All service data and configuration |
| `/root/docker/langfuse/postgres/` | PostgreSQL database files |

---

## Management

```bash
# Follow logs
docker logs -f langfuse

# Stop
cd /root/docker/langfuse && docker compose down

# Start
cd /root/docker/langfuse && docker compose up -d

# Update to latest image
cd /root/docker/langfuse && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 3006/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
