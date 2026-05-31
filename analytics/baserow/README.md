# Baserow — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Open-source no-code database and app builder — a self-hosted alternative to Airtable.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Baserow?

Baserow is an open-source no-code platform for creating databases, managing data, and building internal tools without writing code. It provides a spreadsheet-like interface backed by a real relational database, with support for multiple field types, views, filters, forms, and a REST API for every table.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/analytics/baserow/baserow-ubuntu.sh
chmod +x baserow-ubuntu.sh
sudo bash baserow-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:8089` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8089` | TCP | Web UI / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/baserow/` | All service data and configuration |
| `/root/docker/baserow/data/` | Database and uploaded files |

---

## Management

```bash
# Follow logs
docker logs -f baserow

# Stop
cd /root/docker/baserow && docker compose down

# Start
cd /root/docker/baserow && docker compose up -d

# Update to latest image
cd /root/docker/baserow && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8089/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
