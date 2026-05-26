# Team Fortress 2 Server

Classic class-based team FPS, free to play. Powered by `cm2network/tf2`.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/tf2/tf2-ubuntu.sh
chmod +x tf2-ubuntu.sh
sudo bash tf2-ubuntu.sh
```

## What It Installs

- **TF2 Dedicated Server** — via `cm2network/tf2`

## Ports

| Port | Protocol | Service |
| --- | --- | --- |
| 27015 | TCP + UDP | Game + RCON |
| 27020 | UDP | Source TV |

## Access

In TF2: Servers → Add a Server → `<server-ip>:27015`

Or in console: `connect <server-ip>:27015`

## Hardware Requirements

| Resource | Minimum | Recommended |
| --- | --- | --- |
| RAM | 1 GB | 2 GB |
| CPU | 2 cores | 4 cores |
| Disk | 20 GB | 25 GB |

## Features

- RCON remote administration
- Configurable map and max players
- SourceMod/MetaMod plugin support
- Server data persisted in `./data/`

## Notes

- First start downloads ~15 GB — takes 15–30 minutes
- TF2 is free to play — dedicated server is also free
- GSLT token optional but recommended for public listing
- Add `SRCDS_TOKEN` in `docker-compose.yml` for Steam server list visibility
- Install SourceMod: place files in `./data/tf/addons/`

