# Left 4 Dead 2 Server

Co-op zombie shooter with 4-player campaigns and Versus mode. Powered by `cm2network/l4d2`.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/left4dead2/l4d2-ubuntu.sh
chmod +x l4d2-ubuntu.sh
sudo bash l4d2-ubuntu.sh
```

## What It Installs

- **L4D2 Dedicated Server** — via `cm2network/l4d2`

## Ports

| Port | Protocol | Service |
| --- | --- | --- |
| 27015 | TCP + UDP | Game + RCON |
| 27020 | UDP | Source TV |

## Access

In L4D2 console: `connect <server-ip>:27015`

## Hardware Requirements

| Resource | Minimum | Recommended |
| --- | --- | --- |
| RAM | 1 GB | 2 GB |
| CPU | 2 cores | 4 cores |
| Disk | 15 GB | 20 GB |

## Campaign Maps

| Map ID | Campaign |
| --- | --- |
| `c1m1_hotel` | Dead Center |
| `c2m1_highway` | The Passing |
| `c3m1_plankcountry` | The Swamp Fever |
| `c4m1_milltown_a` | Hard Rain |
| `c5m1_waterfront` | The Parish |

## Features

- RCON remote administration
- SourceMod/MetaMod plugin support
- Up to 8 players (4v4 Versus)
- Server data persisted in `./data/`

## Notes

- First start downloads ~10 GB — takes 15–30 minutes
- L4D2 must be purchased — dedicated server is free
- Add `SRCDS_TOKEN` for Steam server list visibility
- Install SourceMod: place files in `./data/left4dead2/addons/`

