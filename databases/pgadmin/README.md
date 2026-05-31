# pgAdmin — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

The most popular open-source web GUI for PostgreSQL — browse databases, run queries, manage users, and monitor server activity.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is pgAdmin?

pgAdmin 4 is the leading open-source web-based administration tool for PostgreSQL. It provides a full-featured interface for browsing databases, writing and executing SQL queries, viewing execution plans, managing users and roles, monitoring server activity, and performing backups — all from a browser.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/databases/pgadmin/pgadmin-ubuntu.sh
chmod +x pgadmin-ubuntu.sh
sudo bash pgadmin-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:5050` |
| **Email** | Set during install (default: `admin@pgadmin.local`) |
| **Password** | Auto-generated (shown at install) |

> Replace `SERVER_IP` with your server's IP address. Add a PostgreSQL server via right-click on Servers → Register → Server.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `5050` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/pgadmin/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f pgadmin

# Stop the service
cd /root/docker/pgadmin && docker compose down

# Start the service
cd /root/docker/pgadmin && docker compose up -d

# Update to latest image
cd /root/docker/pgadmin && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 5050/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
