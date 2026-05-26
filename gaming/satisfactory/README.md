# Satisfactory Server

3D factory-building and exploration multiplayer. Powered by `wolveix/satisfactory-server`.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/satisfactory/satisfactory-ubuntu.sh
chmod +x satisfactory-ubuntu.sh
sudo bash satisfactory-ubuntu.sh
```

## What It Installs

- **Satisfactory Dedicated Server** — via `wolveix/satisfactory-server`

## Ports

| Port | Protocol | Service |
| --- | --- | --- |
| 7777 | UDP + TCP | Game port |
| 15777 | UDP | Query port |
| 15000 | UDP | Beacon port |

## Access

In Satisfactory: Server Manager → Add Server → `<server-ip>:7777`

## Hardware Requirements

| Resource | Minimum | Recommended |
| --- | --- | --- |
| RAM | 6 GB | 12 GB |
| CPU | 4 cores | 8 cores |
| Disk | 10 GB | 20 GB |

## Features

- Auto-updates server on container start
- Auto-save on player disconnect
- 5 autosave slots
- Save data persisted in `./data/saves/`

## Notes

- First start downloads ~5 GB — takes 10–20 minutes
- Satisfactory must be purchased — dedicated server is free
- Server is managed through the in-game Server Manager UI
- Mods can be installed via the in-game Mod Manager

