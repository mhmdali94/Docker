# V Rising Server

Vampire survival action-RPG multiplayer. Powered by `trueosiris/vrising`.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/v-rising/v-rising-ubuntu.sh
chmod +x v-rising-ubuntu.sh
sudo bash v-rising-ubuntu.sh
```

## What It Installs

- **V Rising Dedicated Server** — via `trueosiris/vrising`

## Ports

| Port | Protocol | Service |
| --- | --- | --- |
| 9876 | UDP | Game port |
| 9877 | UDP | Query port |

## Access

In V Rising: Play → Online → Find Servers → Direct Connect → `<server-ip>:9876`

## Hardware Requirements

| Resource | Minimum | Recommended |
| --- | --- | --- |
| RAM | 4 GB | 8 GB |
| CPU | 4 cores | 8 cores |
| Disk | 5 GB | 10 GB |

## Features

- PvE or PvP game mode (set `GAMEMODE: 1` for PvP)
- Optional server password
- Admin list support via Steam64 IDs
- Save data persisted in `./data/`
- Server settings in `./config/Settings/`

## Notes

- First start downloads ~3 GB — takes 5–10 minutes
- V Rising must be purchased — dedicated server is free
- Admin management: edit `./config/Settings/adminlist.txt` (one Steam64 ID per line)
- Server settings: `./config/Settings/ServerGameSettings.json`

