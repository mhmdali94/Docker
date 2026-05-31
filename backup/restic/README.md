# Restic REST Server — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Lightweight HTTP backend for Restic backups — host your own centralized Restic repository server.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Restic REST Server?

Restic REST Server is an HTTP backend that allows Restic backup clients to store repositories over a network. Restic itself is a fast, secure, and efficient backup program supporting deduplication, encryption, and snapshots. This server lets multiple machines back up to a single centralized location using the standard Restic CLI.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/backup/restic/restic-ubuntu.sh
chmod +x restic-ubuntu.sh
sudo bash restic-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Starts the REST server in no-auth demo mode
- Runs a health check

---

## Access

| | |
|---|---|
| **REST Endpoint** | `http://SERVER_IP:8400` |
| **Username** | None (demo mode — `--no-auth`) |
| **Password** | None (demo mode — `--no-auth`) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8400` | TCP | REST API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/restic/` | All service data and configuration |
| `/root/docker/restic/data/` | Repository storage |

---

## Management

```bash
# Follow logs
docker logs -f restic-rest

# Initialize a repository
restic -r rest:http://SERVER_IP:8400/myrepo init

# Backup a directory
restic -r rest:http://SERVER_IP:8400/myrepo backup /path/to/backup

# Stop
cd /root/docker/restic && docker compose down

# Start
cd /root/docker/restic && docker compose up -d

# Update to latest image
cd /root/docker/restic && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8400/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
