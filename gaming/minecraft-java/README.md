# Minecraft Java Edition Server

The most popular game server in the world. Powered by `itzg/minecraft-server` — the definitive Docker image for Minecraft Java Edition with support for Vanilla, Paper, Spigot, Forge, Fabric, and more.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/minecraft-java/minecraft-java-ubuntu.sh
chmod +x minecraft-java-ubuntu.sh
sudo bash minecraft-java-ubuntu.sh
```

## What It Installs

- **Minecraft Java Server** — via `itzg/minecraft-server`

## Ports

| Port | Service |
| --- | --- |
| 25565 | Minecraft game port (TCP) |
| 25575 | RCON remote console |

## Access

Connect in Minecraft Java Edition: `<server-ip>:25565`

## Hardware Requirements

| Resource | Minimum | Recommended |
| --- | --- | --- |
| RAM | 2 GB | 4–8 GB |
| CPU | 2 cores | 4+ cores |
| Disk | 5 GB | 20+ GB |

## Features

- Vanilla Minecraft or switch to Paper/Spigot/Forge/Fabric via `TYPE` env var
- Auto-accepts EULA
- RCON remote console built-in
- Configurable game mode, difficulty, max players, and view distance
- World data persisted in `./data/`

## Useful Commands

```bash
# Attach to server console
docker attach minecraft-java

# Run server commands via RCON
docker exec minecraft-java rcon-cli

# Detach from console without stopping (Ctrl+P, Ctrl+Q)
```

## Switching Server Type

Edit `docker-compose.yml` and change `TYPE`:

| Value | Description |
| --- | --- |
| `VANILLA` | Official Mojang server (default) |
| `PAPER` | High-performance fork (recommended for plugins) |
| `SPIGOT` | Bukkit-compatible |
| `FORGE` | Mod support |
| `FABRIC` | Modern mod loader |

## Notes

- World files stored in `./data/world/`
- Server properties in `./data/server.properties`
- Online mode (`ONLINE_MODE: true`) requires players to have a valid Minecraft account
- Set `ONLINE_MODE: "false"` for LAN / cracked servers

