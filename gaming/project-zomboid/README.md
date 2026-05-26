# Project Zomboid Server

Hardcore zombie survival multiplayer. Powered by `linuxserver/projectzomboid` — pulls the dedicated server via SteamCMD.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/project-zomboid/project-zomboid-ubuntu.sh
chmod +x project-zomboid-ubuntu.sh
sudo bash project-zomboid-ubuntu.sh
```

## What It Installs

- **Project Zomboid Dedicated Server** — via `linuxserver/projectzomboid`

## Ports

| Port | Protocol | Service |
| --- | --- | --- |
| 16261 | UDP | Game port |
| 16262 | UDP | Direct connection port |

## Access

In Project Zomboid: Join → Direct Connect → `<server-ip>:16261`

## Hardware Requirements

| Resource | Minimum | Recommended |
| --- | --- | --- |
| RAM | 4 GB | 8 GB |
| CPU | 2 cores | 4 cores |
| Disk | 5 GB | 15 GB |

## Features

- Auto-updates via SteamCMD
- Full server configuration via INI files
- Modded server support (Steam Workshop mods)
- Server data persisted in `./data/`

## Notes

- First start downloads ~3 GB — takes 5–10 minutes
- Project Zomboid must be purchased — dedicated server is free
- Server config at `./data/Server/servertest.ini`
- World saves at `./data/Saves/`
- Add mods by editing `WorkshopItems` and `Mods` in the INI file

