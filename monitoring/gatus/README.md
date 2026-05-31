# Gatus — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Gatus is a developer-oriented health monitoring dashboard and status page where endpoints are defined in YAML and checked continuously for uptime, response times, and SSL certificate validity.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Gatus?

Gatus monitors HTTP, TCP, DNS, ICMP, and WebSocket endpoints defined in a single YAML config file. It renders a clean public status page with uptime history and response time graphs, and supports alerting via Slack, Discord, PagerDuty, email, Telegram, and more. Configuration changes are hot-reloaded without a restart.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/monitoring/gatus/gatus-ubuntu.sh
chmod +x gatus-ubuntu.sh
sudo bash gatus-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Writes a default config with sample endpoints
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Status Page** | `http://SERVER_IP:8097` |
| **Username** | None (no auth by default) |
| **Password** | None (no auth by default) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8097` | TCP | Status page / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/gatus/` | All service data and configuration |
| `/root/docker/gatus/config/config.yaml` | Endpoint definitions (edit to add your services) |
| `/root/docker/gatus/data/` | SQLite history database |

---

## Management

```bash
# Follow logs
docker logs -f gatus

# Stop
cd /root/docker/gatus && docker compose down

# Start
cd /root/docker/gatus && docker compose up -d

# Update to latest image
cd /root/docker/gatus && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8097/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
