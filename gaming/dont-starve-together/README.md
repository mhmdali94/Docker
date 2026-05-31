# Don't Starve Together Server — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Don't Starve Together is a cooperative survival game with crafting and dark whimsy. Runs both Overworld and Caves shards. Powered by `jamesits/dst-server`.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Don't Starve Together?

Don't Starve Together (DST) is the multiplayer version of Klei's wilderness survival game. Players cooperate to gather resources, build bases, craft tools, and survive against darkness, monsters, and seasonal challenges. The dedicated server runs two shards — an Overworld and Caves — as separate containers for the full experience.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/dont-starve-together/dst-ubuntu.sh
chmod +x dst-ubuntu.sh
sudo bash dst-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for Klei token, cluster name, and password
- Starts Overworld and Caves shards
- Runs a health check

---

## Connect

| | |
|---|---|
| **In-game** | Browse Servers → filter by name, or Direct Connect → `SERVER_IP:11000` |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `11000` | UDP | Overworld shard |
| `11001` | UDP | Caves shard |
| `27018` | UDP | Steam master server |

---

## Hardware Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 2 GB | 4 GB |
| CPU | 2 cores | 4 cores |
| Disk | 3 GB | 6 GB |

---

## Features

- Overworld + Caves shards running as separate containers
- PvE cooperative mode by default
- Auto-pause when no players are connected
- Configurable password and max players
- World saves persisted in `./master/save/` and `./caves/save/`

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/dst/` | All service data and configuration |
| `/root/docker/dst/master/` | Overworld shard |
| `/root/docker/dst/caves/` | Caves shard |

---

## Management

```bash
# Follow logs
docker logs -f dst-master

# Stop
cd /root/docker/dst && docker compose down

# Start
cd /root/docker/dst && docker compose up -d

# Update to latest image
cd /root/docker/dst && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 11000, 11001, 27018/udp open in firewall
- **Klei server token** required (from accounts.klei.com → Tools → Game Servers)

---

## Notes

- DST is free to play — dedicated server is also free
- Klei token stored in `./master/cluster_token.txt`
- Server config at `./master/cluster.ini`
- Add mods by editing `./master/config/modoverrides.lua`

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
