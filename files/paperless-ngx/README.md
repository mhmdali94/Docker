# Paperless-NGX — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Paperless-NGX is a document management system that scans, indexes, and archives your physical and digital documents using OCR, making them fully searchable.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Paperless-NGX?

Paperless-NGX ingests documents from a watched folder, email, or manual upload, runs OCR on them, and organizes them with tags, correspondents, and document types. It replaces physical filing with a fast, searchable digital archive accessible from any browser.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/files/paperless-ngx/paperless-ngx-ubuntu.sh
chmod +x paperless-ngx-ubuntu.sh
sudo bash paperless-ngx-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:8010` |
| **Username** | `admin` |
| **Password** | Auto-generated during install (displayed in terminal) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8010` | TCP | Web UI / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/paperless-ngx/` | All service data and configuration |
| `/root/docker/paperless-ngx/consume/` | Drop documents here for automatic ingestion |
| `/root/docker/paperless-ngx/media/` | Processed documents |
| `/root/docker/paperless-ngx/export/` | Exported archives |

---

## Management

```bash
# Follow logs
docker logs -f paperless

# Stop
cd /root/docker/paperless-ngx && docker compose down

# Start
cd /root/docker/paperless-ngx && docker compose up -d

# Update to latest image
cd /root/docker/paperless-ngx && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8010/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
