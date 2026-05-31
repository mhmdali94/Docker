# Left 4 Dead 2 Server — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Left 4 Dead 2 is a co-op zombie shooter with 4-player campaigns and Versus mode. Powered by `cm2network/l4d2`.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Left 4 Dead 2?

Left 4 Dead 2 (L4D2) is a cooperative first-person shooter where four survivors fight through zombie-infested campaigns. It features an AI Director that dynamically adjusts difficulty, plus a Versus mode where players control special infected. The dedicated server supports SourceMod plugins for custom game modes and up to 8 players (4v4 Versus).

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/left4dead2/l4d2-ubuntu.sh
chmod +x l4d2-ubuntu.sh
sudo bash l4d2-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for server name and start map
- Starts the game server
- Runs a health check

---

## Connect

| | |
|---|---|
| **In-game** | L4D2 console: `connect SERVER_IP:27015` |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `27015` | TCP + UDP | Game + RCON |
| `27020` | UDP | SourceTV |

---

## Hardware Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 1 GB | 2 GB |
| CPU | 2 cores | 4 cores |
| Disk | 15 GB | 20 GB |

---

## Campaign Maps

| Map ID | Campaign |
|--------|----------|
| `c1m1_hotel` | Dead Center |
| `c2m1_highway` | The Passing |
| `c3m1_plankcountry` | The Swamp Fever |
| `c4m1_milltown_a` | Hard Rain |
| `c5m1_waterfront` | The Parish |

---

## Features

- RCON remote administration
- SourceMod/MetaMod plugin support
- Up to 8 players (4v4 Versus)
- Server data persisted in `./data/`

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/l4d2/` | All service data and configuration |
| `/root/docker/l4d2/data/` | Game files and configs |

---

## Management

```bash
# Follow logs
docker logs -f l4d2

# Stop
cd /root/docker/l4d2 && docker compose down

# Start
cd /root/docker/l4d2 && docker compose up -d

# Update to latest image
cd /root/docker/l4d2 && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 27015/tcp+udp, 27020/udp open in firewall

---

## Notes

- First start downloads ~10 GB — takes 15–30 minutes
- L4D2 must be purchased — dedicated server is free
- Add `SRCDS_TOKEN` for Steam server list visibility
- Install SourceMod: place files in `./data/left4dead2/addons/`

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
