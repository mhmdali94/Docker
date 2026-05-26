# Counter-Strike 2 Server

The world's most popular competitive FPS. Powered by `cm2network/cs2` — the community standard image for CS2 dedicated servers.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/cs2/cs2-ubuntu.sh
chmod +x cs2-ubuntu.sh
sudo bash cs2-ubuntu.sh
```

## What It Installs

- **CS2 Dedicated Server** — via `cm2network/cs2`

## Ports

| Port | Protocol | Service |
| --- | --- | --- |
| 27015 | TCP + UDP | Game + RCON port |
| 27020 | UDP | Source TV / relay |

## Access

In CS2 console: `connect <server-ip>:27015`

## Requirements

**Steam GSLT Token required** — get one free at the Steam game server management page. Without it, the server cannot connect to VAC.

## Hardware Requirements

| Resource | Minimum | Recommended |
| --- | --- | --- |
| RAM | 2 GB | 4 GB |
| CPU | 4 cores | 8 cores |
| Disk | 20 GB | 30 GB |

## Features

- VAC anti-cheat support via GSLT token
- RCON remote administration
- Configurable game type and mode
- Map group rotation support
- Server data persisted in `./data/`

## Game Modes

Set `CS2_GAMETYPE` and `CS2_GAMEMODE` in `docker-compose.yml`:

| Mode | Type | Description |
| --- | --- | --- |
| 0 | 1 | Competitive |
| 0 | 0 | Casual |
| 1 | 0 | Arms Race |
| 1 | 2 | Deathmatch |

## Notes

- First start downloads ~15 GB — takes 10–30 minutes
- CS2 is free to play — clients do not need to purchase it
- GSLT tokens are free but require a Steam account with CS2 owned
- Server configs in `./data/game/csgo/cfg/`

