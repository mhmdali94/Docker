# Palworld Server

Pokémon-with-guns survival multiplayer server. Powered by `thijsvanloef/palworld-server-docker` — the leading community image for Palworld dedicated servers.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/palworld/palworld-ubuntu.sh
chmod +x palworld-ubuntu.sh
sudo bash palworld-ubuntu.sh
```

## What It Installs

- **Palworld Dedicated Server** — via `thijsvanloef/palworld-server-docker`

## Ports

| Port | Protocol | Service |
| --- | --- | --- |
| 8211 | UDP | Game port |
| 27015 | UDP | Steam query port |

## Access

In Palworld: Multiplayer → Join by IP → `<server-ip>:8211`

## Hardware Requirements

| Resource | Minimum | Recommended |
| --- | --- | --- |
| RAM | 8 GB | 16 GB |
| CPU | 4 cores | 8 cores |
| Disk | 10 GB | 20 GB |

## Features

- Auto-updates server on container start
- RCON remote console on port 25575
- Password-protected or public server
- Multi-threading enabled by default
- Save data persisted in `./data/`

## Notes

- First start downloads ~5 GB via SteamCMD — takes 5–15 minutes
- Palworld requires the game to be purchased — dedicated server is free
- Server settings can be customized in `./data/Config/LinuxServer/PalWorldSettings.ini` after first start
- Recommended 16 GB RAM for 16-player servers at full capacity

