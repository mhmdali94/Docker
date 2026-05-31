# n8n — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Low-code workflow automation platform connecting apps, APIs, and services with a visual node-based editor — a self-hosted Zapier alternative.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is n8n?

n8n is an open-source workflow automation tool with 400+ integrations and a visual node editor. Build automations that trigger on webhooks, schedules, or manual execution, connecting services like databases, APIs, email, Slack, and AI providers. Supports custom JavaScript/Python code nodes for complex logic.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/automation/n8n/n8n-ubuntu.sh
chmod +x n8n-ubuntu.sh
sudo bash n8n-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure credentials and encryption key
- Starts the service stack (n8n + PostgreSQL)
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:5678` |
| **Username** | `admin` |
| **Password** | Auto-generated during install (displayed in terminal) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `5678` | TCP | Web UI / Webhook endpoint |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/n8n/` | All service data and configuration |
| `/root/docker/n8n/data/` | n8n data and workflow files |

---

## Management

```bash
# Follow logs
docker logs -f n8n

# Stop
cd /root/docker/n8n && docker compose down

# Start
cd /root/docker/n8n && docker compose up -d

# Update to latest image
cd /root/docker/n8n && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 5678/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
