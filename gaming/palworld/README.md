# Palworld Server — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Palworld is a survival multiplayer game with creature collection and base building. Powered by `thijsvanloef/palworld-server-docker` — the leading community image.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Palworld?

Palworld is an open-world survival crafting game where players capture and train creatures called "Pals" to help with combat, farming, and factory work. The dedicated server supports multiplayer co-op with auto-updates, RCON administration, password protection, and multi-threading for improved performance.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/palworld/palworld-ubuntu.sh
chmod +x palworld-ubuntu.sh
sudo bash palworld-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for server name, description, password, and max players
- Starts the game server
- Runs a health check

---

## Connect

| | |
|---|---|
| **In-game** | Multiplayer → Join by IP → `SERVER_IP:8211` |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8211` | UDP | Game port |
| `27015` | UDP | Steam query port |

---

## Hardware Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 8 GB | 16 GB |
| CPU | 4 cores | 8 cores |
| Disk | 10 GB | 20 GB |

---

## Features

- Auto-updates server on container start
- RCON remote console on port 25575
- Password-protected or public server
- Multi-threading enabled by default
- Save data persisted in `./data/`

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/palworld/` | All service data and configuration |
| `/root/docker/palworld/data/` | Save data and settings |

---

## Management

```bash
# Follow logs
docker logs -f palworld

# Stop
cd /root/docker/palworld && docker compose down

# Start
cd /root/docker/palworld && docker compose up -d

# Update to latest image
cd /root/docker/palworld && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 8211, 27015/udp open in firewall

---

## Notes

- First start downloads ~5 GB via SteamCMD — takes 5–15 minutes
- Palworld requires the game to be purchased — dedicated server is free
- Server settings in `./data/Config/LinuxServer/PalWorldSettings.ini` after first start
- Recommended 16 GB RAM for 16-player servers at full capacity

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
