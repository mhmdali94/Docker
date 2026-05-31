# Adminer — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Single-file universal database management UI supporting MySQL, PostgreSQL, SQLite, MongoDB, and more.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Adminer?

Adminer is a lightweight, full-featured database management tool delivered as a single PHP file. It supports MySQL/MariaDB, PostgreSQL, SQLite, and MongoDB through a clean web interface. Enter your database connection details on the login page — no server-side configuration required. The Dracula dark theme is enabled by default.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/databases/adminer/adminer-ubuntu.sh
chmod +x adminer-ubuntu.sh
sudo bash adminer-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:8086` |
| **Authentication** | Enter DB host, user, and password on the login page |

> Replace `SERVER_IP` with your server's IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8086` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/adminer/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f adminer

# Stop the service
cd /root/docker/adminer && docker compose down

# Start the service
cd /root/docker/adminer && docker compose up -d

# Update to latest image
cd /root/docker/adminer && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 8086/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
