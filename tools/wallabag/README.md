# Wallabag — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Wallabag is a self-hosted read-it-later app — save articles from the web and read them later, clean and ad-free. The open-source alternative to Pocket.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Wallabag?

Wallabag extracts article content from web pages, removes ads and clutter, and presents a clean reading experience. It supports tags, favorites, reading progress tracking, RSS feeds, and offline reading via mobile apps (Android/iOS). Articles can be saved via browser extensions, bookmarklets, or the mobile app. It stores all data in PostgreSQL with Redis for caching.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/wallabag/wallabag-ubuntu.sh
chmod +x wallabag-ubuntu.sh
sudo bash wallabag-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure database password and app secret
- Starts Wallabag, PostgreSQL 15, and Redis 7
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:8095` |
| **Default Username** | `wallabag` |
| **Default Password** | `wallabag` (change immediately) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8095` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/wallabag/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f wallabag

# Stop
cd /root/docker/wallabag && docker compose down

# Start
cd /root/docker/wallabag && docker compose up -d

# Update to latest image
cd /root/docker/wallabag && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8095/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
