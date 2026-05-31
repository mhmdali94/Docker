# Minecraft Java Edition Server — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Minecraft Java Edition is the most popular game server in the world. Powered by `itzg/minecraft-server` — the definitive Docker image with support for Vanilla, Paper, Spigot, Forge, Fabric, and more.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Minecraft Java Edition?

Minecraft Java Edition is the original version of Minecraft with the largest modding community. The dedicated server supports multiple server types including Vanilla (official Mojang), Paper (high-performance), Spigot (Bukkit-compatible), Forge (mod support), and Fabric (modern mod loader). It features RCON for remote administration, configurable game modes, and extensive plugin/mod ecosystems.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/minecraft-java/minecraft-java-ubuntu.sh
chmod +x minecraft-java-ubuntu.sh
sudo bash minecraft-java-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for server name, max players, memory, and game settings
- Starts the game server
- Runs a health check

---

## Connect

| | |
|---|---|
| **In-game** | Multiplayer → Add Server → `SERVER_IP:25565` |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `25565` | TCP | Game port |
| `25575` | TCP | RCON |

---

## Hardware Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 2 GB | 4–8 GB |
| CPU | 2 cores | 4+ cores |
| Disk | 5 GB | 20+ GB |

---

## Switching Server Type

Edit `docker-compose.yml` and change `TYPE`:

| Value | Description |
|-------|-------------|
| `VANILLA` | Official Mojang server (default) |
| `PAPER` | High-performance fork (recommended for plugins) |
| `SPIGOT` | Bukkit-compatible |
| `FORGE` | Mod support |
| `FABRIC` | Modern mod loader |

---

## Features

- Vanilla Minecraft or switch to Paper/Spigot/Forge/Fabric via `TYPE` env var
- Auto-accepts EULA
- RCON remote console built-in
- Configurable game mode, difficulty, max players, and view distance
- World data persisted in `./data/`

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/minecraft-java/` | All service data and configuration |
| `/root/docker/minecraft-java/data/world/` | World files |
| `/root/docker/minecraft-java/data/server.properties` | Server properties |

---

## Management

```bash
# Follow logs
docker logs -f minecraft-java

# Attach to console
docker attach minecraft-java

# Run server commands via RCON
docker exec minecraft-java rcon-cli

# Stop
cd /root/docker/minecraft-java && docker compose down

# Start
cd /root/docker/minecraft-java && docker compose up -d

# Update to latest image
cd /root/docker/minecraft-java && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 25565, 25575/tcp open in firewall

---

## Notes

- World files stored in `./data/world/`
- Server properties in `./data/server.properties`
- Online mode (`ONLINE_MODE: true`) requires valid Minecraft account
- Set `ONLINE_MODE: "false"` for LAN / cracked servers

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
