# Terraria Server — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Terraria is a 2D sandbox adventure multiplayer game. Powered by `ryshe/terraria`.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Terraria?

Terraria is a 2D sandbox game that combines exploration, building, crafting, and combat. Players dig, build, and fight in a procedurally generated world with hundreds of enemies, bosses, and items. The dedicated server supports configurable world size (small/medium/large), three difficulty modes (Normal, Expert, Master), and optional server passwords.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/terraria/terraria-ubuntu.sh
chmod +x terraria-ubuntu.sh
sudo bash terraria-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for world name, size, difficulty, and max players
- Starts the game server
- Runs a health check

---

## Connect

| | |
|---|---|
| **In-game** | Multiplayer → Join via IP → `SERVER_IP:7777` |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `7777` | TCP | Game port |

---

## Hardware Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 512 MB | 1–2 GB |
| CPU | 1 core | 2 cores |
| Disk | 1 GB | 3 GB |

---

## Features

- Auto-creates world on first start
- Configurable world size (small/medium/large)
- Three difficulty modes: Normal, Expert, Master
- Optional server password
- World files persisted in `./world/`

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/terraria/` | All service data and configuration |
| `/root/docker/terraria/world/` | World saves |

---

## Management

```bash
# Follow logs
docker logs -f terraria

# Attach to console
docker attach terraria

# Stop
cd /root/docker/terraria && docker compose down

# Start
cd /root/docker/terraria && docker compose up -d

# Update to latest image
cd /root/docker/terraria && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 7777/tcp open in firewall

---

## Notes

- Terraria must be purchased — dedicated server is free
- World file at `./world/<WorldName>.wld`
- Attach to console: `docker attach terraria` (Ctrl+P+Q to detach)

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
