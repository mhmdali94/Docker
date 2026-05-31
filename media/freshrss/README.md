# FreshRSS — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

FreshRSS is a self-hosted, multi-user RSS and Atom feed aggregator that consolidates all your news sources into one fast, distraction-free reading experience.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is FreshRSS?

FreshRSS aggregates RSS/Atom feeds from blogs, news sites, YouTube channels, and podcasts into a unified inbox. It supports keyboard shortcuts, tags, filters, and a Google Reader–compatible API for mobile apps such as FeedMe, Reeder, and NetNewsWire. Feeds are refreshed automatically every 30 minutes by default.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/media/freshrss/freshrss-ubuntu.sh
chmod +x freshrss-ubuntu.sh
sudo bash freshrss-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure credentials
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:8097` |
| **Username** | Created on first visit (setup wizard) |
| **Password** | Created on first visit (setup wizard) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8097` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/freshrss/` | All service data and configuration |
| `/root/docker/freshrss/data/` | Feed database and user data |
| `/root/docker/freshrss/extensions/` | Optional FreshRSS extensions |

---

## Management

```bash
# Follow logs
docker logs -f freshrss

# Stop
cd /root/docker/freshrss && docker compose down

# Start
cd /root/docker/freshrss && docker compose up -d

# Update to latest image
cd /root/docker/freshrss && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8097/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
