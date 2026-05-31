# Netdata — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Netdata is a real-time performance and health monitoring system for servers, containers, and applications with zero configuration and interactive web dashboards.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Netdata?

Netdata provides high-resolution, real-time system monitoring with sub-second metrics collection. It auto-detects thousands of metrics including CPU, memory, disk, network, processes, containers, and applications — all displayed in a beautifully animated web dashboard. It requires zero configuration to get started and can stream metrics across multiple servers for centralized monitoring.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/monitoring/netdata/netdata-ubuntu.sh
chmod +x netdata-ubuntu.sh
sudo bash netdata-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:19999` |
| **Username** | None (no login required) |
| **Password** | None (no login required) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `19999` | TCP | Netdata Web Dashboard |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/netdata/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f netdata

# Stop
cd /root/docker/netdata && docker compose down

# Start
cd /root/docker/netdata && docker compose up -d

# Update to latest image
cd /root/docker/netdata && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 19999/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
