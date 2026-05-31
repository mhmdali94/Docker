# Shlink — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Shlink is a self-hosted URL shortener with analytics, tracking clicks, referrers, countries, and devices — all on your own server with no third-party tracking.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Shlink?

Shlink is a PHP-based URL shortener that provides a REST API and optional web dashboard for managing short links. It tracks detailed visit analytics including geolocation, referrers, user agents, and device types. It supports custom slugs, QR codes, link expiration, and tag-based organization. A PostgreSQL backend stores all data, and the Shlink Web Client provides a clean dashboard interface.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/shlink/shlink-ubuntu.sh
chmod +x shlink-ubuntu.sh
sudo bash shlink-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure database password and API key
- Starts Shlink, PostgreSQL 15, and Web Client
- Runs a health check

---

## Access

| | |
|---|---|
| **API** | `http://SERVER_IP:8585` |
| **Dashboard** | `http://SERVER_IP:8586` |
| **API Key** | Auto-generated (displayed in terminal) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Connecting Dashboard to API

1. Open the dashboard at port 8586
2. Click **Add server**
3. Enter your API URL: `http://SERVER_IP:8585`
4. Enter your API key (shown at end of install)

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8585` | TCP | Shlink API |
| `8586` | TCP | Shlink Web Dashboard |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/shlink/` | All service data and configuration |
| `/root/docker/shlink/postgres/` | Database storage |

---

## Management

```bash
# Follow logs
docker logs -f shlink

# Stop
cd /root/docker/shlink && docker compose down

# Start
cd /root/docker/shlink && docker compose up -d

# Update to latest image
cd /root/docker/shlink && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 8585, 8586/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
