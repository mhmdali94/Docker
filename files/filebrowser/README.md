# FileBrowser — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

FileBrowser is a lightweight, web-based file manager that lets you access, upload, download, and manage files on your server through a clean browser interface.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is FileBrowser?

FileBrowser provides a web UI for managing files directly on your server without needing FTP or SSH. It supports user management, custom commands, file sharing, and works with any directory on the host. Ideal for quickly browsing or managing server files from any device.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/files/filebrowser/filebrowser-ubuntu.sh
chmod +x filebrowser-ubuntu.sh
sudo bash filebrowser-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:8080` |
| **Username** | `admin` |
| **Password** | `admin` (change on first login) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8080` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/filebrowser/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f filebrowser

# Stop
cd /root/docker/filebrowser && docker compose down

# Start
cd /root/docker/filebrowser && docker compose up -d

# Update to latest image
cd /root/docker/filebrowser && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8080/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
