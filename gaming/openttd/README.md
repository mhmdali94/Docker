# OpenTTD Server — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

OpenTTD is an open-source transport tycoon simulation game. Completely free. Powered by `bateau84/openttd`.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is OpenTTD?

OpenTTD (Open Transport Tycoon Deluxe) is a business simulation game where players build and manage transport networks — trains, buses, trucks, ships, and aircraft — to connect industries and cities. The dedicated server supports up to 8 companies and 16 clients, with configurable map size, starting year, and landscape type.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/openttd/openttd-ubuntu.sh
chmod +x openttd-ubuntu.sh
sudo bash openttd-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for server name, max companies, and max clients
- Starts the game server
- Runs a health check

---

## Connect

| | |
|---|---|
| **In-game** | Multiplayer → Find Server → filter by name, or Add Server → `SERVER_IP:3979` |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3979` | TCP + UDP | Game port |
| `3978` | UDP | Master server heartbeat |

---

## Hardware Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 256 MB | 512 MB |
| CPU | 1 core | 1–2 cores |
| Disk | 500 MB | 1 GB |

---

## Features

- Public server listing on OpenTTD master server
- Configurable map size, starting year, and landscape type
- Up to 8 companies and 16 clients
- Auto-clean inactive companies
- Pause on player join option
- Save files persisted in `./data/save/`

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/openttd/` | All service data and configuration |
| `/root/docker/openttd/data/save/` | Save files |
| `/root/docker/openttd/data/openttd.cfg` | Server configuration |

---

## Management

```bash
# Follow logs
docker logs -f openttd

# Stop
cd /root/docker/openttd && docker compose down

# Start
cd /root/docker/openttd && docker compose up -d

# Update to latest image
cd /root/docker/openttd && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 3979/tcp+udp, 3978/udp open in firewall

---

## Notes

- OpenTTD is completely free — no purchase required
- Server config at `./data/openttd.cfg`
- Default map: 512x512, year 1950
- RCON password used for in-game admin commands: `rcon <password> <command>`

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
