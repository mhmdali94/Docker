# Docmost — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Docmost is a collaborative wiki and documentation platform with real-time editing, rich content support, and workspace management.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Docmost?

Docmost is a modern, open-source Confluence alternative for team documentation. It supports real-time collaborative editing, nested pages, comments, mentions, a rich-text editor with embeds, and workspace-based organization. It is designed for engineering teams, internal wikis, and product documentation.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/docmost/docmost-ubuntu.sh
chmod +x docmost-ubuntu.sh
sudo bash docmost-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure credentials
- Starts Docmost, PostgreSQL, and Redis
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:3004` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3004` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/docmost/` | All service data and configuration |
| `/root/docker/docmost/storage/` | Uploaded files and attachments |
| `/root/docker/docmost/postgres/` | Database storage |

---

## Management

```bash
# Follow logs
docker logs -f docmost

# Stop
cd /root/docker/docmost && docker compose down

# Start
cd /root/docker/docmost && docker compose up -d

# Update to latest image
cd /root/docker/docmost && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 3004/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
