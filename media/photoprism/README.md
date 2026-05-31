# Photoprism — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Photoprism is an AI-powered self-hosted photo management application that automatically classifies, indexes, and makes your photo library fully searchable — a Google Photos alternative you control.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Photoprism?

Photoprism uses TensorFlow to automatically tag photos with scene, object, and color labels, and identifies faces for grouping. It provides a beautiful map view, album management, WebDAV sync, and RAW support. All processing happens locally with no third-party AI services required.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/media/photoprism/photoprism-ubuntu.sh
chmod +x photoprism-ubuntu.sh
sudo bash photoprism-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:2342` |
| **Username** | `admin` |
| **Password** | Auto-generated during install (displayed in terminal) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `2342` | TCP | Web UI / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/photoprism/` | All service data and configuration |
| `/root/docker/photoprism/photos/` | Place your original photos here |
| `/root/docker/photoprism/storage/` | Thumbnails, sidecar files, and metadata |

---

## Management

```bash
# Follow logs
docker logs -f photoprism

# Stop
cd /root/docker/photoprism && docker compose down

# Start
cd /root/docker/photoprism && docker compose up -d

# Update to latest image
cd /root/docker/photoprism && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 2342/tcp open in firewall
- Sufficient disk space for photos and thumbnails

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
