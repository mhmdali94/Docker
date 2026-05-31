# Kavita — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Kavita is a self-hosted digital library server for manga, comics, and books (ePub, PDF, CBZ, CBR) with a built-in web reader and OPDS support.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Kavita?

Kavita provides a fast, beautiful reading experience for your digital book and comic collection. It features automatic metadata fetching, reading progress tracking, collections, reading lists, and an OPDS catalog for connecting e-readers and reading apps. Users can be invited to share libraries with individual reading progress.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/media/kavita/kavita-ubuntu.sh
chmod +x kavita-ubuntu.sh
sudo bash kavita-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:5000` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `5000` | TCP | Web UI / API / OPDS |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/kavita/` | All service data and configuration |
| `/root/docker/kavita/library/` | Place your books, manga, and comics here |
| `/root/docker/kavita/config/` | Application database and settings |

---

## Management

```bash
# Follow logs
docker logs -f kavita

# Stop
cd /root/docker/kavita && docker compose down

# Start
cd /root/docker/kavita && docker compose up -d

# Update to latest image
cd /root/docker/kavita && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 5000/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
