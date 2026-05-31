# Dashy — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Dashy is a highly customizable, self-hosted homepage and dashboard for organizing and accessing all your self-hosted services from one place.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Dashy?

Dashy provides a beautiful, configurable start page with service tiles, widgets, status checks, and custom themes. All configuration is done through a single YAML file, with an optional built-in editor. It supports icon packs, search, bookmarks, and authentication — making it ideal as a unified launcher for your self-hosted stack.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/management/dashy/dashy-ubuntu.sh
chmod +x dashy-ubuntu.sh
sudo bash dashy-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:4000` |
| **Username** | None (no auth by default) |
| **Password** | None (no auth by default) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `4000` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/dashy/` | All service data and configuration |
| `/root/docker/dashy/conf.yml` | Dashboard configuration (services, themes, widgets) |

---

## Management

```bash
# Follow logs
docker logs -f dashy

# Stop
cd /root/docker/dashy && docker compose down

# Start
cd /root/docker/dashy && docker compose up -d

# Update to latest image
cd /root/docker/dashy && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 4000/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
