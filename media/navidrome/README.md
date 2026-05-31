# Navidrome — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Navidrome is a self-hosted music server and streamer compatible with all Subsonic/Airsonic clients, giving you access to your personal music library from anywhere.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Navidrome?

Navidrome scans your music collection and makes it available for streaming via its web interface or any Subsonic-compatible mobile app (DSub, Symfonium, Substreamer, and more). It is lightweight, fast, and supports transcoding, playlists, favorites, and multi-user access with individual libraries and play counts.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/media/navidrome/navidrome-ubuntu.sh
chmod +x navidrome-ubuntu.sh
sudo bash navidrome-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:4533` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `4533` | TCP | Web UI / Subsonic API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/navidrome/` | All service data and configuration |
| `/root/docker/navidrome/music/` | Place your music files here |
| `/root/docker/navidrome/data/` | Database and metadata cache |

---

## Management

```bash
# Follow logs
docker logs -f navidrome

# Stop
cd /root/docker/navidrome && docker compose down

# Start
cd /root/docker/navidrome && docker compose up -d

# Update to latest image
cd /root/docker/navidrome && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 4533/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
