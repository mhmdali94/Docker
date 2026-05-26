# Pterodactyl Panel

Open-source game server management panel. Manage multiple game servers with a web UI, user permissions, resource limits, and a file manager — all running in Docker.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/pterodactyl/pterodactyl-ubuntu.sh
chmod +x pterodactyl-ubuntu.sh
sudo bash pterodactyl-ubuntu.sh
```

## What It Installs

- **Pterodactyl Panel** — Web management UI
- **MySQL 8.0** — Database
- **Redis 7** — Queue and cache

## Ports

| Port | Service |
| --- | --- |
| 8080 | Panel web UI (HTTP) |
| 8443 | Panel web UI (HTTPS) |

## Access

| | URL |
| --- | --- |
| Web UI | `http://<server-ip>:8080` |

## Default Credentials

| Field | Value |
| --- | --- |
| Email | Set during install |
| Username | `admin` |
| Password | Generated during install (shown at end) |

## Architecture

Pterodactyl has two components:

1. **Panel** — the web UI installed by this script (runs in Docker)
2. **Wings** — the game node daemon that must be installed natively on each game server machine

This script installs the Panel only. To run actual game servers, you must install Wings on a separate machine (or the same machine) following the [official Wings guide](https://pterodactyl.io/wings/1.0/installing.html).

## Features

- Multi-server management from one web UI
- Fine-grained user and permission system
- Per-server CPU, RAM, and disk limits
- Built-in file manager, console, and SFTP
- Schedule tasks and automated backups
- Support for 20+ game types via Eggs (config templates)
- REST API for automation

## Supported Games (via Eggs)

Minecraft (Java/Bedrock), Valheim, CS2, Rust, ARK, Terraria, Factorio, and many more — see the [Eggs repository](https://github.com/parkervcp/eggs).

## Notes

- Panel data stored in `./var/`
- Logs in `./logs/`
- Nginx config in `./nginx/`
- TLS certs in `./certs/`
- Reset admin password: `docker exec pterodactyl-panel php artisan p:user:make`
- Recommended: 2 GB+ RAM for the panel alone; each Wings node needs additional RAM per game server

