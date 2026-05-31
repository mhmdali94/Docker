# Nextcloud — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Nextcloud is a self-hosted cloud platform that gives you full control over your files, calendar, contacts, and collaboration tools without relying on third-party services.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Nextcloud?

Nextcloud is an open-source alternative to Google Drive and Dropbox. It includes file sync and share, a built-in office suite, calendar, contacts, video calls, and over 300 apps in its app store. Suitable for personal use and small teams who need full data ownership.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/files/nextcloud/nextcloud-ubuntu.sh
chmod +x nextcloud-ubuntu.sh
sudo bash nextcloud-ubuntu.sh
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
| **Password** | Auto-generated during install (displayed in terminal) |

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
| `/root/docker/nextcloud/` | All service data and configuration |
| `/root/docker/nextcloud/data/` | Nextcloud files and application data |
| `/root/docker/nextcloud/db/` | MariaDB database |

---

## Management

```bash
# Follow logs
docker logs -f nextcloud

# Stop
cd /root/docker/nextcloud && docker compose down

# Start
cd /root/docker/nextcloud && docker compose up -d

# Update to latest image
cd /root/docker/nextcloud && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8080/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
