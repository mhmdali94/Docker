# OpenRA Server

Open-source reimplementation of classic Command & Conquer real-time strategy games. Completely free. Powered by `rmoriz/openra`.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/openra/openra-ubuntu.sh
chmod +x openra-ubuntu.sh
sudo bash openra-ubuntu.sh
```

## What It Installs

- **OpenRA Dedicated Server** — via `rmoriz/openra`

## Ports

| Port | Protocol | Service |
| --- | --- | --- |
| 1234 | TCP | Game port |

## Access

In OpenRA: Multiplayer → Join Game → Direct Connect → `<server-ip>:1234`

## Hardware Requirements

| Resource | Minimum | Recommended |
| --- | --- | --- |
| RAM | 256 MB | 512 MB |
| CPU | 1 core | 1 core |
| Disk | 500 MB | 1 GB |

## Available Games (Mods)

| Mod | Game |
| --- | --- |
| `ra` | Red Alert (default) |
| `cnc` | Tiberian Dawn (C&C) |
| `d2k` | Dune 2000 |

## Features

- Advertises to OpenRA master server automatically
- Supports all three classic game mods
- No original game files required — assets are open-source
- Server data persisted in `./data/`

## Notes

- OpenRA is completely free — no purchase required
- Change game mod: edit `OPENRA_MOD` in `docker-compose.yml` and restart
- Server shows up in OpenRA's multiplayer lobby automatically

