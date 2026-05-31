# Jellyfin — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Jellyfin is a free, open-source media server that lets you collect, manage, and stream your movies, TV shows, music, and photos to any device with no subscription fees.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Jellyfin?

Jellyfin is a complete open-source alternative to Plex and Emby. It supports hardware-accelerated transcoding, multi-user libraries with parental controls, live TV and DVR, and native apps for Android, iOS, Apple TV, Roku, Fire TV, and web browsers — all with no cloud dependency and no cost.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/media/jellyfin/jellyfin-ubuntu.sh
chmod +x jellyfin-ubuntu.sh
sudo bash jellyfin-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:8096` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8096` | TCP | Web UI / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/jellyfin/` | All service data and configuration |
| `/root/docker/jellyfin/config/` | Jellyfin configuration and metadata |
| `/root/docker/jellyfin/cache/` | Transcoding and image cache |
| `/root/docker/jellyfin/media/` | Place your media files here |

---

## Management

```bash
# Follow logs
docker logs -f jellyfin

# Stop
cd /root/docker/jellyfin && docker compose down

# Start
cd /root/docker/jellyfin && docker compose up -d

# Update to latest image
cd /root/docker/jellyfin && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8096/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
