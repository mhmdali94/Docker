# TubeArchivist — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

TubeArchivist is a self-hosted YouTube media server that lets you subscribe to channels, download videos, and browse your personal video archive with full-text search.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is TubeArchivist?

TubeArchivist downloads and organizes YouTube videos into a local media archive. It supports channel and playlist subscriptions, automatic scheduled downloads, metadata indexing via Elasticsearch, and a clean web interface for browsing and playing your archived content. Ideal for archivists and anyone who wants an offline YouTube library.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/media/tubearchivist/tubearchivist-ubuntu.sh
chmod +x tubearchivist-ubuntu.sh
sudo bash tubearchivist-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure credentials
- Tunes `vm.max_map_count` for Elasticsearch
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:8098` |
| **Username** | `admin` |
| **Password** | Auto-generated during install (displayed in terminal) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8098` | TCP | Web UI / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/tubearchivist/` | All service data and configuration |
| `/root/docker/tubearchivist/youtube/` | Downloaded video files |
| `/root/docker/tubearchivist/cache/` | Temporary download cache |
| `/root/docker/tubearchivist/es/` | Elasticsearch index data |

---

## Management

```bash
# Follow logs
docker logs -f tubearchivist

# Stop
cd /root/docker/tubearchivist && docker compose down

# Start
cd /root/docker/tubearchivist && docker compose up -d

# Update to latest image
cd /root/docker/tubearchivist && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8098/tcp open in firewall
- At least 4 GB RAM (Elasticsearch requirement)
- Sufficient disk space for video archives

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
