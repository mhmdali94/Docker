# Ghost — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Ghost is a professional open-source publishing platform and CMS for blogs, newsletters, and membership sites with a clean editor and built-in SEO.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Ghost?

Ghost is a headless Node.js CMS designed for publishers and content creators. It provides a distraction-free editor, native newsletter support, paid memberships, subscription management, SEO optimization, and a modern API-first architecture. It is widely used for professional blogs and media publications.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/ghost/ghost-ubuntu.sh
chmod +x ghost-ubuntu.sh
sudo bash ghost-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for your site URL
- Generates secure database credentials
- Starts Ghost and MySQL
- Runs a health check

---

## Access

| | |
|---|---|
| **Blog** | `http://SERVER_IP:2368` |
| **Admin Panel** | `http://SERVER_IP:2368/ghost` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address (or configured domain).

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `2368` | TCP | Web UI / Admin |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/ghost/` | All service data and configuration |
| `/root/docker/ghost/content/` | Themes, images, and data |
| `/root/docker/ghost/mysql/` | Database storage |

---

## Management

```bash
# Follow logs
docker logs -f ghost

# Stop
cd /root/docker/ghost && docker compose down

# Start
cd /root/docker/ghost && docker compose up -d

# Update to latest image
cd /root/docker/ghost && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 2368/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
