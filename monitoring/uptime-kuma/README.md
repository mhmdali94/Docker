# Uptime Kuma — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Uptime Kuma is a self-hosted monitoring tool to track uptime for websites and services with a beautiful, modern web UI.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Uptime Kuma?

Uptime Kuma monitors the availability and response time of HTTP(s) endpoints, TCP ports, DNS records, Docker containers, and more. It supports multiple notification channels (Telegram, Discord, Slack, email, and 90+ others), displays uptime history in status pages, and provides certificate expiry monitoring. The lightweight Node.js backend uses SQLite for storage with no external database required.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/monitoring/uptime-kuma/uptime-kuma-ubuntu.sh
chmod +x uptime-kuma-ubuntu.sh
sudo bash uptime-kuma-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:3001` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3001` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/uptime-kuma/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f uptime-kuma

# Stop
cd /root/docker/uptime-kuma && docker compose down

# Start
cd /root/docker/uptime-kuma && docker compose up -d

# Update to latest image
cd /root/docker/uptime-kuma && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 3001/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
