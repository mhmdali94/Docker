# Team Fortress 2 Server — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Team Fortress 2 is a classic class-based team FPS, free to play. Powered by `cm2network/tf2`.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Team Fortress 2?

Team Fortress 2 (TF2) is a team-based first-person shooter with nine unique classes, each with distinct abilities and playstyles. The dedicated server supports multiple game modes including Payload, Capture the Flag, Control Point, and Mann vs. Machine. It supports SourceMod/MetaMod plugins for custom game modes and RCON for remote administration.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/tf2/tf2-ubuntu.sh
chmod +x tf2-ubuntu.sh
sudo bash tf2-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for server name, max players, and start map
- Starts the game server
- Runs a health check

---

## Connect

| | |
|---|---|
| **In-game** | Servers → Add a Server → `SERVER_IP:27015` or console: `connect SERVER_IP:27015` |

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
| Disk | 20 GB | 25 GB |

---

## Features

- RCON remote administration
- Configurable map and max players
- SourceMod/MetaMod plugin support
- Server data persisted in `./data/`

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/tf2/` | All service data and configuration |
| `/root/docker/tf2/data/` | Game files and configs |

---

## Management

```bash
# Follow logs
docker logs -f tf2

# Stop
cd /root/docker/tf2 && docker compose down

# Start
cd /root/docker/tf2 && docker compose up -d

# Update to latest image
cd /root/docker/tf2 && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 27015/tcp+udp, 27020/udp open in firewall

---

## Notes

- First start downloads ~15 GB — takes 15–30 minutes
- TF2 is free to play — dedicated server is also free
- GSLT token optional but recommended for public listing
- Add `SRCDS_TOKEN` in `docker-compose.yml` for Steam server list visibility
- Install SourceMod: place files in `./data/tf/addons/`

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
