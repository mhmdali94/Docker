# Audiobookshelf — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Audiobookshelf is a self-hosted audiobook and podcast server with a polished web player, progress sync, and mobile apps for iOS and Android.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Audiobookshelf?

Audiobookshelf organizes your audiobook and podcast library with metadata fetching, chapter support, bookmarks, and playback speed controls. It syncs progress across devices via its mobile apps and provides a streaming-ready web interface — a complete replacement for Audible or Pocket Casts for self-hosted users.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/media/audiobookshelf/audiobookshelf-ubuntu.sh
chmod +x audiobookshelf-ubuntu.sh
sudo bash audiobookshelf-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:13378` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `13378` | TCP | Web UI / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/audiobookshelf/` | All service data and configuration |
| `/root/docker/audiobookshelf/audiobooks/` | Place audiobook files here |
| `/root/docker/audiobookshelf/podcasts/` | Place podcast files here |
| `/root/docker/audiobookshelf/config/` | Application configuration |
| `/root/docker/audiobookshelf/metadata/` | Covers and metadata cache |

---

## Management

```bash
# Follow logs
docker logs -f audiobookshelf

# Stop
cd /root/docker/audiobookshelf && docker compose down

# Start
cd /root/docker/audiobookshelf && docker compose up -d

# Update to latest image
cd /root/docker/audiobookshelf && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 13378/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
