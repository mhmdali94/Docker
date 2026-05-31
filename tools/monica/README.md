# Monica — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Monica is an open-source personal CRM for tracking relationships, interactions, reminders, and notes about the people in your life.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Monica?

Monica is a personal relationship manager designed to help you be more intentional about your relationships. It stores contact details, tracks conversations and activities, sets reminders for birthdays and follow-ups, and records notes about interactions. It is a privacy-respecting, self-hosted alternative to keeping track of people in scattered notes.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/monica/monica-ubuntu.sh
chmod +x monica-ubuntu.sh
sudo bash monica-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure credentials
- Starts Monica and MariaDB
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:8096` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8096` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/monica/` | All service data and configuration |
| `/root/docker/monica/storage/` | Uploaded photos and files |
| `/root/docker/monica/mysql/` | Database storage |

---

## Management

```bash
# Follow logs
docker logs -f monica

# Stop
cd /root/docker/monica && docker compose down

# Start
cd /root/docker/monica && docker compose up -d

# Update to latest image
cd /root/docker/monica && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8096/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
