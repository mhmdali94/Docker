# V Rising Server — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

V Rising is a vampire survival action-RPG multiplayer game. Powered by `trueosiris/vrising`.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is V Rising?

V Rising is an open-world vampire survival game where players awaken as a weakened vampire and must rebuild their castle, conquer territories, and dominate the living. The dedicated server supports PvE and PvP modes, optional server passwords, and admin management via Steam64 IDs. Save data and server settings are fully configurable.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/v-rising/v-rising-ubuntu.sh
chmod +x v-rising-ubuntu.sh
sudo bash v-rising-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for server name, password, max players, and optional admin ID
- Starts the game server
- Runs a health check

---

## Connect

| | |
|---|---|
| **In-game** | Play → Online → Find Servers → Direct Connect → `SERVER_IP:9876` |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `9876` | UDP | Game port |
| `9877` | UDP | Query port |

---

## Hardware Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 4 GB | 8 GB |
| CPU | 4 cores | 8 cores |
| Disk | 5 GB | 10 GB |

---

## Features

- PvE or PvP game mode (set `GAMEMODE: 1` for PvP)
- Optional server password
- Admin list support via Steam64 IDs
- Save data persisted in `./data/`
- Server settings in `./config/Settings/`

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/v-rising/` | All service data and configuration |
| `/root/docker/v-rising/data/` | Save data |
| `/root/docker/v-rising/config/Settings/` | Server settings |

---

## Management

```bash
# Follow logs
docker logs -f v-rising

# Stop
cd /root/docker/v-rising && docker compose down

# Start
cd /root/docker/v-rising && docker compose up -d

# Update to latest image
cd /root/docker/v-rising && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 9876, 9877/udp open in firewall

---

## Notes

- First start downloads ~3 GB — takes 5–10 minutes
- V Rising must be purchased — dedicated server is free
- Admin management: edit `./config/Settings/adminlist.txt` (one Steam64 ID per line)
- Server settings: `./config/Settings/ServerGameSettings.json`

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
