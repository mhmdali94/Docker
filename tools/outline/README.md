# Outline — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Outline is a fast, collaborative knowledge base and wiki with real-time editing, Markdown support, nested documents, and granular permissions. A self-hosted Notion alternative.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Outline?

Outline is a modern wiki and knowledge base designed for teams. It supports real-time collaborative editing, rich Markdown with embeds, nested document collections, full-text search, and granular sharing permissions. It integrates with Slack, Google, and GitHub for authentication. Outline is ideal for internal documentation, team handbooks, and company wikis.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/outline/outline-ubuntu.sh
chmod +x outline-ubuntu.sh
sudo bash outline-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure database password and secrets
- Starts Outline, PostgreSQL 15, and Redis 7
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:3003` |
| **Login** | Requires OAuth provider or SMTP magic-link |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3003` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/outline/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f outline

# Stop
cd /root/docker/outline && docker compose down

# Start
cd /root/docker/outline && docker compose up -d

# Update to latest image
cd /root/docker/outline && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 3003/tcp open in firewall
- SMTP or OAuth provider for authentication

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
