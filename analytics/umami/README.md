# Umami — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Simple, privacy-focused, open-source web analytics — a self-hosted alternative to Google Analytics.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Umami?

Umami is a lightweight, privacy-first web analytics tool that collects only the data you need with no cookies and no personal information. It provides a clean real-time dashboard with page views, visitors, sessions, referrers, and device breakdowns. Multiple websites can be tracked from a single Umami instance.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/analytics/umami/umami-ubuntu.sh
chmod +x umami-ubuntu.sh
sudo bash umami-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure database credentials and app secret
- Starts the service stack (Umami + PostgreSQL)
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:3002` |
| **Username** | `admin` |
| **Password** | `umami` (change immediately after first login) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3002` | TCP | Web UI / Tracking API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/umami/` | All service data and configuration |
| `/root/docker/umami/pgdata/` | PostgreSQL database files |

---

## Management

```bash
# Follow logs
docker logs -f umami

# Stop
cd /root/docker/umami && docker compose down

# Start
cd /root/docker/umami && docker compose up -d

# Update to latest image
cd /root/docker/umami && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 3002/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
