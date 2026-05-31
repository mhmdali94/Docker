# Redash — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Open-source data visualization and dashboarding tool — write SQL queries, build charts, and share dashboards from any data source.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Redash?

Redash is an open-source platform for querying, visualizing, and sharing data. Teams write SQL (or use query builders) against databases like PostgreSQL, MySQL, BigQuery, and Redshift, then build interactive charts and dashboards. Supports scheduled query refreshes, alerts, and sharing dashboards with non-technical stakeholders.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/analytics/redash/redash-ubuntu.sh
chmod +x redash-ubuntu.sh
sudo bash redash-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure credentials and secret keys
- Starts the service stack (server, worker, PostgreSQL, Redis)
- Initializes the database and runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:5001` |
| **First-run setup** | `http://SERVER_IP:5001/setup` |
| **Username** | Created via setup wizard |
| **Password** | Created via setup wizard |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `5001` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/redash/` | All service data and configuration |
| `/root/docker/redash/postgres/` | PostgreSQL database files |

---

## Management

```bash
# Follow logs
docker logs -f redash-server

# Stop
cd /root/docker/redash && docker compose down

# Start
cd /root/docker/redash && docker compose up -d

# Update to latest image
cd /root/docker/redash && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 5001/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
