# Immich — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Immich is a high-performance, self-hosted photo and video management solution with AI-powered face recognition, smart search, and native mobile apps for iOS and Android.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Immich?

Immich is a Google Photos alternative that runs entirely on your own server. It features automatic photo backup from your phone, AI-based face grouping and object recognition, map view, shared albums, and a fast responsive web interface. The iOS and Android apps make mobile backup seamless.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/media/immich/immich-ubuntu.sh
chmod +x immich-ubuntu.sh
sudo bash immich-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:2283` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address. Use the same URL in the mobile app settings.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `2283` | TCP | Web UI / API / Mobile sync |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/immich/` | All service data and configuration |
| `/root/docker/immich/library/` | Photo and video storage |
| `/root/docker/immich/model-cache/` | AI/ML model cache |
| `/root/docker/immich/pgdata/` | PostgreSQL database |

---

## Management

```bash
# Follow logs
docker logs -f immich-server

# Stop
cd /root/docker/immich && docker compose down

# Start
cd /root/docker/immich && docker compose up -d

# Update to latest image
cd /root/docker/immich && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 2283/tcp open in firewall
- Sufficient disk space for photos and videos

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
