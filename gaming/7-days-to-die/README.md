# 7 Days to Die Server — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

7 Days to Die is a zombie survival game with tower defense, crafting, and base building. Powered by `vinanrra/7dtd-server`.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is 7 Days to Die?

7 Days to Die is an open-world survival horror game combining first-person shooter, tower defense, and RPG elements. Players scavenge resources, build fortifications, and survive against increasingly difficult zombie hordes that attack every seven days. The dedicated server supports multiplayer co-op or PvP with configurable zombie counts, player limits, and game modes.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/7-days-to-die/7dtd-ubuntu.sh
chmod +x 7dtd-ubuntu.sh
sudo bash 7dtd-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for server name, max players, and game world
- Starts the game server
- Runs a health check

---

## Connect

| | |
|---|---|
| **In-game** | Join Game → Direct Connect → `SERVER_IP:26900` |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `26900` | TCP + UDP | Game port |
| `26901–26902` | UDP | Steam ports |
| `8080` | TCP | Control Panel |
| `8082` | TCP | Web Dashboard |

---

## Hardware Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 6 GB | 12 GB |
| CPU | 4 cores | 8 cores |
| Disk | 10 GB | 20 GB |

---

## Features

- Navezgane (hand-crafted) or Random World Generation (RWG) map
- Web Control Panel for server management
- Web Dashboard for server stats
- Configurable zombie count, player limit, and game mode
- EAC (Easy Anti-Cheat) disabled for LAN/private use

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/7dtd/` | All service data and configuration |
| `/root/docker/7dtd/data/serverconfig.xml` | Server configuration |
| `/root/docker/7dtd/data/saves/` | World saves |

---

## Management

```bash
# Follow logs
docker logs -f 7dtd

# Stop
cd /root/docker/7dtd && docker compose down

# Start
cd /root/docker/7dtd && docker compose up -d

# Update to latest image
cd /root/docker/7dtd && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 26900/tcp+udp, 26901–26902/udp, 8080, 8082/tcp open in firewall

---

## Notes

- First start downloads ~8 GB — takes 15–30 minutes
- 7 Days to Die must be purchased — dedicated server is free
- Server config at `./data/serverconfig.xml`
- World saves at `./data/saves/`
- Control Panel at `http://SERVER_IP:8080` (password set during install)

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
