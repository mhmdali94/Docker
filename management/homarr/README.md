# Homarr — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Homarr is a modern, sleek self-hosted dashboard that shows live statistics from Sonarr, Radarr, Jellyfin, and dozens of other services alongside your service links.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Homarr?

Homarr provides a drag-and-drop configurable homepage for your self-hosted stack. It connects to Docker to auto-discover running containers and integrates with popular media, monitoring, and download services to surface live data. Tiles are arranged visually via an in-browser editor without any YAML required.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/management/homarr/homarr-ubuntu.sh
chmod +x homarr-ubuntu.sh
sudo bash homarr-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:7575` |
| **Username** | None (no auth by default) |
| **Password** | None (no auth by default) |

> Replace `SERVER_IP` with your server's actual IP address. Use the pencil (edit) icon to add and arrange service tiles.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `7575` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/homarr/` | All service data and configuration |
| `/root/docker/homarr/configs/` | Dashboard layout and service configs |
| `/root/docker/homarr/icons/` | Custom service icons |

---

## Management

```bash
# Follow logs
docker logs -f homarr

# Stop
cd /root/docker/homarr && docker compose down

# Start
cd /root/docker/homarr && docker compose up -d

# Update to latest image
cd /root/docker/homarr && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 7575/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
