# OpenTTD Server

Open-source transport tycoon simulation game. Completely free. Powered by `bateau84/openttd`.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/openttd/openttd-ubuntu.sh
chmod +x openttd-ubuntu.sh
sudo bash openttd-ubuntu.sh
```

## What It Installs

- **OpenTTD Dedicated Server** — via `bateau84/openttd`

## Ports

| Port | Protocol | Service |
| --- | --- | --- |
| 3979 | TCP + UDP | Game port |
| 3978 | UDP | Master server heartbeat |

## Access

In OpenTTD: Multiplayer → Find Server → filter by name, or Add Server → `<server-ip>:3979`

## Hardware Requirements

| Resource | Minimum | Recommended |
| --- | --- | --- |
| RAM | 256 MB | 512 MB |
| CPU | 1 core | 1–2 cores |
| Disk | 500 MB | 1 GB |

## Features

- Public server listing on OpenTTD master server
- Configurable map size, starting year, and landscape type
- Up to 8 companies and 16 clients
- Auto-clean inactive companies
- Pause on player join option
- Save files persisted in `./data/save/`

## Notes

- OpenTTD is completely free — no purchase required
- Server config at `./data/openttd.cfg`
- Default map: 512×512, year 1950
- RCON password used for in-game admin commands: `rcon <password> <command>`

