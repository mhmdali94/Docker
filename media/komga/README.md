# Komga — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Komga is a self-hosted comic book and manga server with a built-in web reader, OPDS catalog, and metadata management for CBZ, CBR, PDF, and folder-based series.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Komga?

Komga organizes your comic and manga collection into libraries and series, automatically importing metadata and cover art. It provides a clean web reader, reading progress tracking, user management, and OPDS support for connecting apps like Panels, Chunky, and Challenger Comics. REST API available for integrations.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/media/komga/komga-ubuntu.sh
chmod +x komga-ubuntu.sh
sudo bash komga-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:8076` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8076` | TCP | Web UI / API / OPDS |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/komga/` | All service data and configuration |
| `/root/docker/komga/data/` | Place your comic/manga files here |
| `/root/docker/komga/config/` | Application database and settings |

---

## Management

```bash
# Follow logs
docker logs -f komga

# Stop
cd /root/docker/komga && docker compose down

# Start
cd /root/docker/komga && docker compose up -d

# Update to latest image
cd /root/docker/komga && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8076/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
