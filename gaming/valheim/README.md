# Valheim Server

Viking survival multiplayer server. Powered by `lloesche/valheim-server` — pulls the dedicated server via SteamCMD, supports auto-updates and scheduled backups.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/valheim/valheim-ubuntu.sh
chmod +x valheim-ubuntu.sh
sudo bash valheim-ubuntu.sh
```

## What It Installs

- **Valheim Dedicated Server** — via `lloesche/valheim-server`

## Ports

| Port | Protocol | Service |
| --- | --- | --- |
| 2456 | UDP | Game port |
| 2457 | UDP | Game port +1 |
| 2458 | UDP | Game port +2 |

## Access

In Valheim: Join Game → Add Server → `<server-ip>:2456`

## Hardware Requirements

| Resource | Minimum | Recommended |
| --- | --- | --- |
| RAM | 2 GB | 4 GB |
| CPU | 2 cores | 4 cores |
| Disk | 5 GB | 10 GB |

## Features

- Auto-updates Valheim server daily at 04:00
- Automatic world backups daily at 03:00
- Backup files kept for 3 days
- World and config data persisted in `./config/` and `./data/`

## Notes

- First start downloads ~1 GB via SteamCMD — takes 5–10 minutes
- Password must be at least 5 characters and cannot match the server name
- Valheim requires the game to be purchased — server is free but clients must own it
- World saves: `./config/worlds/`

