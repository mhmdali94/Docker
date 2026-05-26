# Terraria Server

2D sandbox adventure multiplayer. Powered by `linuxserver/terraria`.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/terraria/terraria-ubuntu.sh
chmod +x terraria-ubuntu.sh
sudo bash terraria-ubuntu.sh
```

## What It Installs

- **Terraria Dedicated Server** — via `linuxserver/terraria`

## Ports

| Port | Protocol | Service |
| --- | --- | --- |
| 7777 | TCP | Game port |

## Access

In Terraria: Multiplayer → Join via IP → `<server-ip>:7777`

## Hardware Requirements

| Resource | Minimum | Recommended |
| --- | --- | --- |
| RAM | 512 MB | 1–2 GB |
| CPU | 1 core | 2 cores |
| Disk | 1 GB | 3 GB |

## Features

- Auto-creates world on first start
- Configurable world size (small/medium/large)
- Three difficulty modes: Normal, Expert, Master
- Optional server password
- World files persisted in `./world/`

## Notes

- Terraria must be purchased — dedicated server is free
- World file at `./world/<WorldName>.wld`
- Attach to console: `docker attach terraria` (Ctrl+P+Q to detach)

