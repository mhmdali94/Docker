# Satisfactory Server — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Satisfactory is a 3D factory-building and exploration multiplayer game. Powered by `wolveix/satisfactory-server`.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Satisfactory?

Satisfactory is a first-person open-world factory building game where players construct massive automated production lines on an alien planet. The dedicated server supports multiplayer co-op with auto-updates, auto-save on player disconnect, and in-game Server Manager for configuration. It requires significant RAM and CPU for smooth multiplayer performance.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/satisfactory/satisfactory-ubuntu.sh
chmod +x satisfactory-ubuntu.sh
sudo bash satisfactory-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for max players
- Starts the game server
- Runs a health check

---

## Connect

| | |
|---|---|
| **In-game** | Server Manager → Add Server → `SERVER_IP:7777` |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `7777` | UDP + TCP | Game port |
| `15777` | UDP | Query port |
| `15000` | UDP | Beacon port |

---

## Hardware Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 6 GB | 12 GB |
| CPU | 4 cores | 8 cores |
| Disk | 10 GB | 20 GB |

---

## Features

- Auto-updates server on container start
- Auto-save on player disconnect
- 5 autosave slots
- Save data persisted in `./data/saves/`

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/satisfactory/` | All service data and configuration |
| `/root/docker/satisfactory/data/saves/` | Save files |

---

## Management

```bash
# Follow logs
docker logs -f satisfactory

# Stop
cd /root/docker/satisfactory && docker compose down

# Start
cd /root/docker/satisfactory && docker compose up -d

# Update to latest image
cd /root/docker/satisfactory && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 7777/tcp+udp, 15777, 15000/udp open in firewall

---

## Notes

- First start downloads ~5 GB — takes 10–20 minutes
- Satisfactory must be purchased — dedicated server is free
- Server is managed through the in-game Server Manager UI
- Mods can be installed via the in-game Mod Manager

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
