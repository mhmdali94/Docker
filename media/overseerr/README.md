# Overseerr — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Overseerr is a media request and discovery platform that lets users request movies and TV shows, with automatic approval workflows connected to Radarr and Sonarr.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Overseerr?

Overseerr bridges your media server (Plex or Jellyfin) with your download automation (Radarr/Sonarr). Users can browse and request content through a polished interface — requests are automatically sent to the appropriate downloader and appear in your media server once complete. It includes a full notification system and granular user permissions.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/media/overseerr/overseerr-ubuntu.sh
chmod +x overseerr-ubuntu.sh
sudo bash overseerr-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:5055` |
| **Username** | Created via setup wizard on first visit |
| **Password** | Created via setup wizard on first visit |

> Replace `SERVER_IP` with your server's actual IP address. Complete the setup wizard to connect your Plex or Jellyfin server and configure Radarr/Sonarr.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `5055` | TCP | Web UI / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/overseerr/` | All service data and configuration |
| `/root/docker/overseerr/config/` | Database and application settings |

---

## Management

```bash
# Follow logs
docker logs -f overseerr

# Stop
cd /root/docker/overseerr && docker compose down

# Start
cd /root/docker/overseerr && docker compose up -d

# Update to latest image
cd /root/docker/overseerr && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 5055/tcp open in firewall
- A running Plex or Jellyfin media server

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
