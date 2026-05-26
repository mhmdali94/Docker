# Factorio Server

Automation and factory-building multiplayer. Powered by `factoriotools/factorio` — the official Docker image maintained by the Factorio community.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/factorio/factorio-ubuntu.sh
chmod +x factorio-ubuntu.sh
sudo bash factorio-ubuntu.sh
```

## What It Installs

- **Factorio Dedicated Server** — via `factoriotools/factorio:stable`

## Ports

| Port | Protocol | Service |
| --- | --- | --- |
| 34197 | UDP | Game port |
| 27015 | TCP | RCON |

## Access

In Factorio: Multiplayer → Browse Public Games or Connect to Address → `<server-ip>:34197`

## Hardware Requirements

| Resource | Minimum | Recommended |
| --- | --- | --- |
| RAM | 1 GB | 2–4 GB |
| CPU | 2 cores | 4 cores |
| Disk | 2 GB | 5 GB |

## Features

- Auto-generates new save on first start
- 10-minute autosave with 5 slots
- RCON remote console
- Mod support via `./mods/` directory
- Save files persisted in `./saves/`

## Notes

- Factorio must be purchased — dedicated server is free
- Drop mods (`.zip` files) in `./mods/` and restart
- Server settings in `./config/server-settings.json`
- Admins-only commands by default (`allow_commands: admins-only`)

