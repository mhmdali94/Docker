# Homepage — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Homepage is a fast, modern self-hosted dashboard that displays live stats from your services and Docker containers through a clean, YAML-configured interface.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Homepage?

Homepage provides a central start page for all your self-hosted services. It integrates with over 100 services (Sonarr, Radarr, Grafana, Portainer, and more) to show live data alongside your service tiles. Docker socket integration enables automatic container discovery and status display.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/management/homepage/homepage-ubuntu.sh
chmod +x homepage-ubuntu.sh
sudo bash homepage-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Writes default config files
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:3333` |
| **Username** | None (no auth by default) |
| **Password** | None (no auth by default) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3333` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/homepage/` | All service data and configuration |
| `/root/docker/homepage/config/` | YAML config files (services, bookmarks, widgets) |

---

## Management

```bash
# Follow logs
docker logs -f homepage

# Stop
cd /root/docker/homepage && docker compose down

# Start
cd /root/docker/homepage && docker compose up -d

# Update to latest image
cd /root/docker/homepage && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 3333/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
