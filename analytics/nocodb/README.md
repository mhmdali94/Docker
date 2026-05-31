# NocoDB — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Open-source Airtable alternative that turns any SQL database into a smart spreadsheet with a no-code interface.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is NocoDB?

NocoDB is an open-source platform that transforms SQL databases into collaborative spreadsheet-like interfaces. It supports multiple views (grid, gallery, form, kanban), automated workflows, REST and GraphQL APIs, and integrations with Slack, email, and webhooks. Works on top of existing PostgreSQL, MySQL, MariaDB, or SQLite databases.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/analytics/nocodb/nocodb-ubuntu.sh
chmod +x nocodb-ubuntu.sh
sudo bash nocodb-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure credentials and JWT secret
- Starts the service stack (NocoDB + PostgreSQL)
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:8088` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8088` | TCP | Web UI / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/nocodb/` | All service data and configuration |
| `/root/docker/nocodb/postgres/` | PostgreSQL database files |

---

## Management

```bash
# Follow logs
docker logs -f nocodb

# Stop
cd /root/docker/nocodb && docker compose down

# Start
cd /root/docker/nocodb && docker compose up -d

# Update to latest image
cd /root/docker/nocodb && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8088/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
