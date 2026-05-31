# Portainer CE — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Portainer Community Edition is the most popular web-based Docker management UI, providing a full interface for managing containers, images, volumes, networks, and compose stacks.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Portainer CE?

Portainer CE gives you a powerful graphical interface to manage your Docker environment without the command line. It supports container deployment from compose files, image management, log streaming, resource monitoring, and multi-environment management. Ideal for developers and sysadmins who prefer a visual workflow.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/management/portainer/portainer-ubuntu.sh
chmod +x portainer-ubuntu.sh
sudo bash portainer-ubuntu.sh
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
| **Web UI** | `https://SERVER_IP:9443` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address. You have **5 minutes** after first start to create your admin account before the setup wizard locks.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `9443` | TCP | Web UI (HTTPS) |
| `8000` | TCP | Edge agent tunnel |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/portainer/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f portainer

# Stop
cd /root/docker/portainer && docker compose down

# Start
cd /root/docker/portainer && docker compose up -d

# Update to latest image
cd /root/docker/portainer && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 9443/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
