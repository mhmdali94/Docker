# Minetest Server — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Minetest is a free and open-source Minecraft-like voxel game engine. Completely free — no purchase required. Powered by `linuxserver/minetest`.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Minetest?

Minetest is an open-source voxel game engine that supports multiple game modes, mods, and texture packs. It is completely free — both the client and server are open-source. Popular games like MineClone2 provide a Minecraft-like experience. The dedicated server supports public server listing, PvP configuration, and extensive modding.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/minetest/minetest-ubuntu.sh
chmod +x minetest-ubuntu.sh
sudo bash minetest-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for server name, admin username, and max players
- Starts the game server
- Runs a health check

---

## Connect

| | |
|---|---|
| **In-game** | Join Game → Enter address `SERVER_IP` and port `30000` |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `30000` | UDP | Game port |

---

## Hardware Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 512 MB | 1–2 GB |
| CPU | 1 core | 2 cores |
| Disk | 500 MB | 2 GB |

---

## Features

- 100% free — game and server both open-source
- Supports game mods and texture packs
- Configurable PvP and damage
- Public server announcement built-in
- World data persisted in `./data/worlds/`

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/minetest/` | All service data and configuration |
| `/root/docker/minetest/data/worlds/` | World saves |
| `/root/docker/minetest/data/minetest.conf` | Server configuration |

---

## Management

```bash
# Follow logs
docker logs -f minetest

# Stop
cd /root/docker/minetest && docker compose down

# Start
cd /root/docker/minetest && docker compose up -d

# Update to latest image
cd /root/docker/minetest && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 30000/udp open in firewall

---

## Notes

- No purchase required — Minetest is free
- Install games/mods: place in `./data/games/` or `./data/mods/`
- Popular game: MineClone2 (Minecraft-like) — download from minetest.net
- Server config at `./data/minetest.conf`

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
