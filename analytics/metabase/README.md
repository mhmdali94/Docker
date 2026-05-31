# Metabase — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Open-source business intelligence and dashboarding tool — explore and visualize data without writing SQL.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Metabase?

Metabase is an open-source BI platform that lets non-technical users ask questions and build charts from databases using a point-and-click interface. It connects to PostgreSQL, MySQL, MongoDB, BigQuery, and many other sources. Features include interactive dashboards, scheduled reports, alerts, and embedded analytics.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/analytics/metabase/metabase-ubuntu.sh
chmod +x metabase-ubuntu.sh
sudo bash metabase-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure database credentials
- Starts the service stack (Metabase + PostgreSQL)
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:3007` |
| **Username** | Created on first visit (setup wizard) |
| **Password** | Created on first visit (setup wizard) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3007` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/metabase/` | All service data and configuration |
| `/root/docker/metabase/postgres/` | PostgreSQL database files |

---

## Management

```bash
# Follow logs
docker logs -f metabase

# Stop
cd /root/docker/metabase && docker compose down

# Start
cd /root/docker/metabase && docker compose up -d

# Update to latest image
cd /root/docker/metabase && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 3007/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
