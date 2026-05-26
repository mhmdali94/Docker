# Garry's Mod Server

Sandbox physics game with massive modding ecosystem. Powered by `FragSoc/garrysmod-docker`.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/garrys-mod/garrysmod-ubuntu.sh
chmod +x garrysmod-ubuntu.sh
sudo bash garrysmod-ubuntu.sh
```

## What It Installs

- **Garry's Mod Dedicated Server** — via `FragSoc/garrysmod-docker`

## Ports

| Port | Protocol | Service |
| --- | --- | --- |
| 27015 | TCP + UDP | Game + RCON |
| 27005 | UDP | Client port |

## Access

In GMod console: `connect <server-ip>:27015`

Or via Steam Server Browser.

## Hardware Requirements

| Resource | Minimum | Recommended |
| --- | --- | --- |
| RAM | 1 GB | 2–4 GB |
| CPU | 2 cores | 4 cores |
| Disk | 8 GB | 15 GB |

## Popular Game Modes

| Mode | Description |
| --- | --- |
| `sandbox` | Default — build and experiment |
| `terrortown` | TTT — social deduction |
| `darkrp` | RP with economy |
| `prophunt` | Hide and seek |

## Features

- Steam Workshop collection support (`SRCDS_WORKSHOPCOLLECTION`)
- RCON remote administration
- Lua addon support
- Server data persisted in `./data/`

## Notes

- First start downloads ~5 GB — takes 5–15 minutes
- Garry's Mod must be purchased — dedicated server is free
- Add Workshop collection ID to `SRCDS_WORKSHOPCOLLECTION` in `docker-compose.yml`
- Lua addons: place in `./data/garrysmod/addons/`

