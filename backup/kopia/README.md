# Kopia — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Fast, encrypted, deduplicated backup tool with a web UI — backs up to local disk, S3, Backblaze B2, and more.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Kopia?

Kopia is a modern, open-source backup tool offering end-to-end encryption, deduplication, compression, and incremental backups. It supports local filesystem repositories as well as remote backends including Amazon S3, Backblaze B2, Google Cloud Storage, Azure Blob, and SFTP. The web UI provides policy management, scheduled snapshots, and browsing of backup contents. The host filesystem is mounted read-only at `/data` inside the container.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/backup/kopia/kopia-ubuntu.sh
chmod +x kopia-ubuntu.sh
sudo bash kopia-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure admin password and repository password
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:51515` |
| **Username** | `admin` |
| **Password** | Auto-generated during install (displayed in terminal) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `51515` | TCP | Web UI / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/kopia/` | All service data and configuration |
| `/root/docker/kopia/repository/` | Local backup repository |
| `/root/docker/kopia/cache/` | Kopia cache directory |

---

## Management

```bash
# Follow logs
docker logs -f kopia

# Stop
cd /root/docker/kopia && docker compose down

# Start
cd /root/docker/kopia && docker compose up -d

# Update to latest image
cd /root/docker/kopia && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 51515/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
