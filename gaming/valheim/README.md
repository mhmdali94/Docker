# Valheim Server — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Valheim is a Viking survival multiplayer game with procedural worlds. Powered by `lloesche/valheim-server` — supports auto-updates and scheduled backups.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Valheim?

Valheim is a survival and exploration game set in a procedurally generated world inspired by Norse mythology. Players build bases, craft weapons, tame animals, and fight mythological bosses. The dedicated server supports auto-updates via SteamCMD, daily automated world backups, and configurable server settings. Password must be at least 5 characters and cannot match the server name.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/valheim/valheim-ubuntu.sh
chmod +x valheim-ubuntu.sh
sudo bash valheim-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for server name, world name, and server password
- Configures auto-update and backup schedules
- Starts the game server
- Runs a health check

---

## Connect

| | |
|---|---|
| **In-game** | Join Game → Add Server → `SERVER_IP:2456` |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `2456` | UDP | Game port |
| `2457` | UDP | Game port +1 |
| `2458` | UDP | Game port +2 |

---

## Hardware Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 2 GB | 4 GB |
| CPU | 2 cores | 4 cores |
| Disk | 5 GB | 10 GB |

---

## Features

- Auto-updates Valheim server daily at 04:00
- Automatic world backups daily at 03:00
- Backup files kept for 3 days
- World and config data persisted in `./config/` and `./data/`

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/valheim/` | All service data and configuration |
| `/root/docker/valheim/config/worlds/` | World saves |
| `/root/docker/valheim/config/` | Server configuration |

---

## Management

```bash
# Follow logs
docker logs -f valheim

# Stop
cd /root/docker/valheim && docker compose down

# Start
cd /root/docker/valheim && docker compose up -d

# Update to latest image
cd /root/docker/valheim && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 2456–2458/udp open in firewall

---

## Notes

- First start downloads ~1 GB via SteamCMD — takes 5–10 minutes
- Password must be at least 5 characters and cannot match the server name
- Valheim requires the game to be purchased — server is free but clients must own it
- World saves: `./config/worlds/`

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
