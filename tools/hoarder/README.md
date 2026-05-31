# Hoarder — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Hoarder is an AI-powered bookmark manager with automatic tagging, full-text search, and screenshot capture for saved links, notes, and images.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Hoarder?

Hoarder is a self-hosted bookmark and read-later manager. When you save a link, it automatically fetches the page, takes a screenshot, and uses AI (optional OpenAI integration) to generate tags. It supports full-text search via Meilisearch, browser extensions for one-click saving, and a mobile-friendly web UI.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/hoarder/hoarder-ubuntu.sh
chmod +x hoarder-ubuntu.sh
sudo bash hoarder-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Optionally prompts for an OpenAI API key for AI tagging
- Starts Hoarder, Meilisearch, and a headless Chrome browser
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:3777` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3777` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/hoarder/` | All service data and configuration |
| `/root/docker/hoarder/data/` | Bookmarks and metadata |
| `/root/docker/hoarder/meilisearch/` | Search index |

---

## Management

```bash
# Follow logs
docker logs -f hoarder

# Stop
cd /root/docker/hoarder && docker compose down

# Start
cd /root/docker/hoarder && docker compose up -d

# Update to latest image
cd /root/docker/hoarder && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 3777/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
