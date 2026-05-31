# Memos — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Memos is a lightweight, open-source note-taking service with a Twitter-like timeline interface for capturing and organizing quick thoughts and notes.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Memos?

Memos is a privacy-first, self-hosted note-taking tool with a microblog-style feed. Notes support Markdown, tags, links, and code blocks. It is minimal and fast, designed for quick capture of thoughts, ideas, and snippets without the overhead of a full knowledge base system.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/memos/memos-ubuntu.sh
chmod +x memos-ubuntu.sh
sudo bash memos-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Starts the Memos container
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:5230` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `5230` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/memos/` | All service data and configuration |
| `/root/docker/memos/data/` | SQLite database and uploaded files |

---

## Management

```bash
# Follow logs
docker logs -f memos

# Stop
cd /root/docker/memos && docker compose down

# Start
cd /root/docker/memos && docker compose up -d

# Update to latest image
cd /root/docker/memos && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 5230/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
