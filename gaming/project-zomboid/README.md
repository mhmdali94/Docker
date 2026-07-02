# Project Zomboid Server — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Project Zomboid is a hardcore zombie survival multiplayer game. Powered by `renegademaster/zomboid-dedicated-server` — pulls the dedicated server via SteamCMD.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Project Zomboid?

Project Zomboid is an isometric survival horror game set in a zombie apocalypse. Players must scavenge, build, craft, and fight to survive in a persistent open world. The dedicated server supports multiplayer co-op with Steam Workshop mod support, configurable difficulty, and persistent world saves.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/project-zomboid/project-zomboid-ubuntu.sh
chmod +x project-zomboid-ubuntu.sh
sudo bash project-zomboid-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for server name and max players
- Starts the game server
- Runs a health check

---

## Connect

| | |
|---|---|
| **In-game** | Join → Direct Connect → `SERVER_IP:16261` |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `16261` | UDP | Game port |
| `16262` | UDP | Direct connection port |

---

## Hardware Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 4 GB | 8 GB |
| CPU | 2 cores | 4 cores |
| Disk | 5 GB | 15 GB |

---

## Features

- Auto-updates via SteamCMD
- Full server configuration via INI files
- Modded server support (Steam Workshop mods)
- Server data persisted in `./data/`

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/project-zomboid/` | All service data and configuration |
| `/root/docker/project-zomboid/data/` | Saves and server config |

---

## Management

```bash
# Follow logs
docker logs -f project-zomboid

# Stop
cd /root/docker/project-zomboid && docker compose down

# Start
cd /root/docker/project-zomboid && docker compose up -d

# Update to latest image
cd /root/docker/project-zomboid && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 16261, 16262/udp open in firewall

---

## Notes

- First start downloads ~3 GB — takes 5–10 minutes
- Project Zomboid must be purchased — dedicated server is free
- Server config at `./data/Server/servertest.ini`
- World saves at `./data/Saves/`
- Add mods by editing `WorkshopItems` and `Mods` in the INI file

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
