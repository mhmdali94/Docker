# Don't Starve Together Server

Cooperative survival with crafting and dark whimsy. Powered by `jamesits/dst-server` — runs both the Overworld and Caves shards.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/dont-starve-together/dst-ubuntu.sh
chmod +x dst-ubuntu.sh
sudo bash dst-ubuntu.sh
```

## What It Installs

- **DST Master (Overworld) shard** — `dst-master`
- **DST Caves shard** — `dst-caves`

## Ports

| Port | Protocol | Service |
| --- | --- | --- |
| 11000 | UDP | Overworld shard |
| 11001 | UDP | Caves shard |
| 27018 | UDP | Steam master server |

## Access

In Don't Starve Together: Browse Servers → filter by name, or use Direct Connect → `<server-ip>:11000`

## Requirements

**Klei server token required** — log in at accounts.klei.com → Tools → Game Servers → "Add New Server".

## Hardware Requirements

| Resource | Minimum | Recommended |
| --- | --- | --- |
| RAM | 2 GB | 4 GB |
| CPU | 2 cores | 4 cores |
| Disk | 3 GB | 6 GB |

## Features

- Overworld + Caves shards running as separate containers
- PvE cooperative mode by default
- Auto-pause when no players are connected
- Configurable password and max players
- World saves persisted in `./master/save/` and `./caves/save/`

## Notes

- DST is free to play — dedicated server is also free
- Klei token stored in `./master/cluster_token.txt`
- Server config at `./master/cluster.ini`
- Add mods by editing `./master/config/modoverrides.lua`

