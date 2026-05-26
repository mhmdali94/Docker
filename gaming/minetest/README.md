# Minetest Server

Free and open-source Minecraft-like voxel game engine. Completely free — no purchase required. Powered by `linuxserver/minetest`.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/minetest/minetest-ubuntu.sh
chmod +x minetest-ubuntu.sh
sudo bash minetest-ubuntu.sh
```

## What It Installs

- **Minetest Dedicated Server** — via `linuxserver/minetest`

## Ports

| Port | Protocol | Service |
| --- | --- | --- |
| 30000 | UDP | Game port |

## Access

In Minetest: Join Game → Enter address `<server-ip>` and port `30000`

## Hardware Requirements

| Resource | Minimum | Recommended |
| --- | --- | --- |
| RAM | 512 MB | 1–2 GB |
| CPU | 1 core | 2 cores |
| Disk | 500 MB | 2 GB |

## Features

- 100% free — game and server both open-source
- Supports game mods and texture packs
- Configurable PvP and damage
- Public server announcement built-in
- World data persisted in `./data/worlds/`

## Notes

- No purchase required — Minetest is free
- Install games/mods: place in `./data/games/` or `./data/mods/`
- Popular game: MineClone2 (Minecraft-like) — download from minetest.net/downloads
- Server config at `./data/minetest.conf`

