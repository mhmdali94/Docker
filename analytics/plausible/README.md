# Plausible Analytics — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Lightweight, privacy-friendly web analytics — a self-hosted alternative to Google Analytics with no cookies and no personal data collection.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Plausible Analytics?

Plausible is an open-source, privacy-first web analytics platform. It provides real-time visitor counts, top pages, referral sources, and geographic data in a clean single-page dashboard. The lightweight tracking script (less than 1 KB) has minimal impact on page load times and requires no cookie consent banner.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/analytics/plausible/plausible-ubuntu.sh
chmod +x plausible-ubuntu.sh
sudo bash plausible-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure credentials and secret key
- Starts the service stack (Plausible + PostgreSQL + ClickHouse)
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:8100` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8100` | TCP | Web UI / Tracking API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/plausible/` | All service data and configuration |
| `/root/docker/plausible/pgdata/` | PostgreSQL database files |
| `/root/docker/plausible/clickhouse-data/` | ClickHouse event data |

---

## Management

```bash
# Follow logs
docker logs -f plausible

# Stop
cd /root/docker/plausible && docker compose down

# Start
cd /root/docker/plausible && docker compose up -d

# Update to latest image
cd /root/docker/plausible && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8100/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
