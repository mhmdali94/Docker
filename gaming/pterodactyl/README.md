# Pterodactyl Panel — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Pterodactyl is an open-source game server management panel with a web UI, user permissions, resource limits, and a file manager — all running in Docker.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Pterodactyl?

Pterodactyl is a game server management panel designed for both individuals and hosting companies. It provides a web-based interface to manage multiple game servers with fine-grained user permissions, per-server CPU/RAM/disk limits, a built-in file manager, console access, and automated backups. The panel runs in Docker, while game servers run on separate Wings nodes.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/pterodactyl/pterodactyl-ubuntu.sh
chmod +x pterodactyl-ubuntu.sh
sudo bash pterodactyl-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for server IP and admin email
- Generates secure database password and app key
- Starts Panel, MySQL 8.0, and Redis 7
- Creates admin user
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:8080` |
| **Username** | `admin` |
| **Password** | Auto-generated during install (displayed in terminal) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8080` | TCP | Panel web UI (HTTP) |
| `8443` | TCP | Panel web UI (HTTPS) |

---

## Architecture

Pterodactyl has two components:

1. **Panel** — the web UI installed by this script (runs in Docker)
2. **Wings** — the game node daemon installed on each game server machine

This script installs the Panel only. To run actual game servers, install Wings on a separate machine following the [official Wings guide](https://pterodactyl.io/wings/1.0/installing.html).

---

## Features

- Multi-server management from one web UI
- Fine-grained user and permission system
- Per-server CPU, RAM, and disk limits
- Built-in file manager, console, and SFTP
- Schedule tasks and automated backups
- Support for 20+ game types via Eggs (config templates)
- REST API for automation

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/pterodactyl/` | All service data and configuration |
| `/root/docker/pterodactyl/var/` | Panel data |
| `/root/docker/pterodactyl/logs/` | Logs |

---

## Management

```bash
# Follow logs
docker logs -f pterodactyl-panel

# Stop
cd /root/docker/pterodactyl && docker compose down

# Start
cd /root/docker/pterodactyl && docker compose up -d

# Update to latest image
cd /root/docker/pterodactyl && docker compose pull && docker compose up -d

# Reset admin password
docker exec pterodactyl-panel php artisan p:user:make
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 8080, 8443/tcp open in firewall
- 2 GB+ RAM for the panel; Wings nodes need additional RAM per game server

---

## Notes

- Panel data stored in `./var/`
- Nginx config in `./nginx/`
- TLS certs in `./certs/`

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
