# Dockge — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Dockge is a modern, compose-first Docker stack manager that lets you manage all your docker-compose stacks through a clean, reactive web interface.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Dockge?

Dockge focuses on Docker Compose stacks rather than individual containers. You can create, edit, start, stop, and update stacks directly from the browser, with real-time terminal output and log streaming. Stacks are stored in `/opt/stacks` and remain portable as standard compose files.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/management/dockge/dockge-ubuntu.sh
chmod +x dockge-ubuntu.sh
sudo bash dockge-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:5521` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `5521` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/dockge/` | Dockge application data |
| `/opt/stacks/` | Docker Compose stacks managed by Dockge |

---

## Management

```bash
# Follow logs
docker logs -f dockge

# Stop
cd /root/docker/dockge && docker compose down

# Start
cd /root/docker/dockge && docker compose up -d

# Update to latest image
cd /root/docker/dockge && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 5521/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
