# Duplicati — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Free backup solution that stores encrypted, incremental, compressed backups to cloud storage or local targets.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Duplicati?

Duplicati is a free, open-source backup tool that supports encrypted, deduplicated, and incremental backups to a wide range of destinations including S3, Backblaze B2, SFTP, OneDrive, Google Drive, FTP, and local storage. It provides a web-based scheduler and runs as a background service with email notifications for backup status. The entire host filesystem is mounted read-only at `/source` inside the container.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/backup/duplicati/duplicati-ubuntu.sh
chmod +x duplicati-ubuntu.sh
sudo bash duplicati-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:8200` |
| **Username** | Not required |
| **Password** | Set in Settings on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8200` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/duplicati/` | All service data and configuration |
| `/root/docker/duplicati/config/` | Duplicati configuration |
| `/root/docker/duplicati/backups/` | Default local backup destination |

---

## Management

```bash
# Follow logs
docker logs -f duplicati

# Stop
cd /root/docker/duplicati && docker compose down

# Start
cd /root/docker/duplicati && docker compose up -d

# Update to latest image
cd /root/docker/duplicati && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8200/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
