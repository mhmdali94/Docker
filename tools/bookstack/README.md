# BookStack — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

BookStack is a simple, self-hosted wiki and documentation platform organized around Books, Chapters, and Pages.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is BookStack?

BookStack provides a structured, hierarchical approach to documentation. Content is organized into Books containing Chapters containing Pages, making it easy to maintain organized internal wikis, runbooks, and knowledge bases. It features a WYSIWYG editor, Markdown support, full-text search, role-based permissions, and SSO integration.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/bookstack/bookstack-ubuntu.sh
chmod +x bookstack-ubuntu.sh
sudo bash bookstack-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure database credentials
- Starts BookStack and MariaDB
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:6875` |
| **Email** | `admin@admin.com` |
| **Password** | `password` |

> Replace `SERVER_IP` with your server's actual IP address.
> **Change the default password immediately after first login.**

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `6875` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/bookstack/` | All service data and configuration |
| `/root/docker/bookstack/config/` | Application configuration and uploads |
| `/root/docker/bookstack/mysql/` | Database storage |

---

## Management

```bash
# Follow logs
docker logs -f bookstack

# Stop
cd /root/docker/bookstack && docker compose down

# Start
cd /root/docker/bookstack && docker compose up -d

# Update to latest image
cd /root/docker/bookstack && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 6875/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
