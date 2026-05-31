# Cachet — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Cachet is an open-source status page system for displaying real-time service health, posting incident updates, and communicating transparently with your users during outages.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Cachet?

Cachet provides a polished public-facing status page where you can group your services into components, report incidents with timeline updates, schedule maintenance windows, and notify subscribers by email. A REST API enables automated status updates from your monitoring systems.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/monitoring/cachet/cachet-ubuntu.sh
chmod +x cachet-ubuntu.sh
sudo bash cachet-ubuntu.sh
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
| **Status Page** | `http://SERVER_IP:8099` |
| **Admin Dashboard** | `http://SERVER_IP:8099/dashboard` |
| **Username** | Created on first visit (setup wizard) |
| **Password** | Created on first visit (setup wizard) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8099` | TCP | Web UI / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/cachet/` | All service data and configuration |
| `/root/docker/cachet/postgres/` | PostgreSQL database |

---

## Management

```bash
# Follow logs
docker logs -f cachet

# Stop
cd /root/docker/cachet && docker compose down

# Start
cd /root/docker/cachet && docker compose up -d

# Update to latest image
cd /root/docker/cachet && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8099/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
