# ARK: Survival Evolved Server

Dinosaur survival multiplayer with taming, building, and PvP. Powered by `hermsi1337/docker-ark-survival-evolved`.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/ark/ark-ubuntu.sh
chmod +x ark-ubuntu.sh
sudo bash ark-ubuntu.sh
```

## What It Installs

- **ARK: Survival Evolved Dedicated Server** — via `hermsi1337/docker-ark-survival-evolved`

## Ports

| Port | Protocol | Service |
| --- | --- | --- |
| 7777 | UDP | Game port |
| 7778 | UDP | Raw UDP port |
| 27015 | UDP | Steam query |
| 32330 | TCP | RCON |

## Access

In ARK: Join ARK → filter by server name, or use Session IP `<server-ip>:7777`

## Hardware Requirements

| Resource | Minimum | Recommended |
| --- | --- | --- |
| RAM | 8 GB | 16 GB |
| CPU | 4 cores | 8+ cores |
| Disk | 60 GB | 80 GB |

## Available Maps

| Map | Notes |
| --- | --- |
| `TheIsland` | Default starter map |
| `TheCenter` | Free DLC |
| `Ragnarok` | Free DLC, large map |
| `Aberration` | Paid DLC |
| `Extinction` | Paid DLC |

## Features

- Configurable XP, taming, and harvesting multipliers
- RCON remote administration
- Cluster support for multi-map servers
- Game data persisted in `./data/`

## Notes

- **First start downloads ~60 GB — takes 1–2 hours**
- ARK: Survival Evolved is free to play (base game) — dedicated server is free
- Admin commands in-game: open console → `EnableCheats <admin-password>`
- Server config at `./data/ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini`

