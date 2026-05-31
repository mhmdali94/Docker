# Beszel — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Beszel is a lightweight server monitoring hub with a clean web dashboard for tracking CPU, memory, disk, network, and Docker container metrics across multiple servers.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Beszel?

Beszel provides a minimal-overhead monitoring solution for self-hosted environments. A central hub collects metrics from lightweight agents installed on remote servers, displaying everything in a unified real-time dashboard. It is notably simpler to deploy than Grafana/Prometheus while covering the most common server health metrics.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/monitoring/beszel/beszel-ubuntu.sh
chmod +x beszel-ubuntu.sh
sudo bash beszel-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:8090` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8090` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/beszel/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f beszel

# Stop
cd /root/docker/beszel && docker compose down

# Start
cd /root/docker/beszel && docker compose up -d

# Update to latest image
cd /root/docker/beszel && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8090/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
