# 7 Days to Die Server

Zombie survival with tower defense and crafting. Powered by `linuxserver/7dtd`.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/7-days-to-die/7dtd-ubuntu.sh
chmod +x 7dtd-ubuntu.sh
sudo bash 7dtd-ubuntu.sh
```

## What It Installs

- **7 Days to Die Dedicated Server** — via `linuxserver/7dtd`

## Ports

| Port | Protocol | Service |
| --- | --- | --- |
| 26900 | TCP + UDP | Game port |
| 26901–26902 | UDP | Steam ports |
| 8080 | TCP | Control Panel |
| 8082 | TCP | Web Dashboard |

## Access

In 7 Days to Die: Join Game → Direct Connect → `<server-ip>:26900`

## Hardware Requirements

| Resource | Minimum | Recommended |
| --- | --- | --- |
| RAM | 6 GB | 12 GB |
| CPU | 4 cores | 8 cores |
| Disk | 10 GB | 20 GB |

## Features

- Navezgane (hand-crafted) or Random World Generation (RWG) map
- Web Control Panel for server management
- Web Dashboard for server stats
- Configurable zombie count, player limit, and game mode
- EAC (Easy Anti-Cheat) disabled for LAN/private use

## Notes

- First start downloads ~8 GB — takes 15–30 minutes
- 7 Days to Die must be purchased — dedicated server is free
- Server config at `./data/serverconfig.xml`
- World saves at `./data/saves/`
- Control Panel at `http://<server-ip>:8080` (password set during install)

