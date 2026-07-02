# ARK: Survival Evolved Server — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

ARK: Survival Evolved is a dinosaur survival multiplayer game with taming, building, and PvP. Powered by `hermsi/ark-server`.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is ARK: Survival Evolved?

ARK is an open-world survival game where players tame dinosaurs, build bases, craft weapons, and explore a massive island filled with prehistoric creatures. The dedicated server supports up to 70 players with configurable XP, taming, and harvesting multipliers. Multiple DLC maps are available including The Island, Ragnarok, Aberration, and Extinction.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/ark/ark-ubuntu.sh
chmod +x ark-ubuntu.sh
sudo bash ark-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for server name, map, and max players
- Starts the game server
- Runs a health check

---

## Connect

| | |
|---|---|
| **In-game** | Join ARK → filter by name, or Session IP `SERVER_IP:7777` |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `7777` | UDP | Game port |
| `7778` | UDP | Raw UDP port |
| `27015` | UDP | Steam query |
| `32330` | TCP | RCON |

---

## Hardware Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 8 GB | 16 GB |
| CPU | 4 cores | 8+ cores |
| Disk | 60 GB | 80 GB |

---

## Available Maps

| Map | Notes |
|-----|-------|
| `TheIsland` | Default starter map |
| `TheCenter` | Free DLC |
| `Ragnarok` | Free DLC, large map |
| `Aberration` | Paid DLC |
| `Extinction` | Paid DLC |

---

## Features

- Configurable XP, taming, and harvesting multipliers
- RCON remote administration
- Cluster support for multi-map servers
- Game data persisted in `./data/`

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/ark/` | All service data and configuration |
| `/root/docker/ark/data/` | Game data and saves |

---

## Management

```bash
# Follow logs
docker logs -f ark

# Stop
cd /root/docker/ark && docker compose down

# Start
cd /root/docker/ark && docker compose up -d

# Update to latest image
cd /root/docker/ark && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 7777, 7778, 27015/udp and 32330/tcp open in firewall

---

## Notes

- First start downloads ~60 GB — takes 1–2 hours
- ARK: Survival Evolved is free to play — dedicated server is free
- Admin commands in-game: open console → `EnableCheats <admin-password>`
- Server config at `./data/ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini`

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
