# PeerTube — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

PeerTube is a self-hosted, federated video hosting platform — a YouTube alternative with no ads, no algorithms, and no data collection that connects with the Fediverse.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is PeerTube?

PeerTube lets you host, manage, and stream videos on your own server while federating with other PeerTube instances and Mastodon. It uses WebTorrent for peer-assisted video delivery to reduce server bandwidth. Features include channels, playlists, live streaming, chapters, subtitles, and a full admin panel.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/media/peertube/peertube-ubuntu.sh
chmod +x peertube-ubuntu.sh
sudo bash peertube-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for your domain name (required for federation)
- Generates secure credentials
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://YOUR_DOMAIN:9300` |
| **Admin Email** | `admin@YOUR_DOMAIN` |
| **Admin Password** | Run: `docker logs peertube 2>&1 \| grep -i password` |

> A real domain name is required. Replace `YOUR_DOMAIN` with the domain you provided during install.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `9300` | TCP | Web UI / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/peertube/` | All service data and configuration |
| `/root/docker/peertube/data/` | Video files and thumbnails |
| `/root/docker/peertube/postgres/` | PostgreSQL database |
| `/root/docker/peertube/redis/` | Redis cache |

---

## Management

```bash
# Follow logs
docker logs -f peertube

# Stop
cd /root/docker/peertube && docker compose down

# Start
cd /root/docker/peertube && docker compose up -d

# Update to latest image
cd /root/docker/peertube && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- A real domain name pointing to this server
- Port 9300/tcp open in firewall
- Sufficient disk space for video storage

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
