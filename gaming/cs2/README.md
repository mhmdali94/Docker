# Counter-Strike 2 Server — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Counter-Strike 2 is the world's most popular competitive FPS. Powered by `cm2network/cs2` — the community standard for CS2 dedicated servers.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Counter-Strike 2?

Counter-Strike 2 (CS2) is Valve's next-generation competitive FPS built on the Source 2 engine. The dedicated server supports competitive, casual, deathmatch, and arms race modes with VAC anti-cheat, RCON administration, and map group rotation. A free Steam GSLT token is required for VAC-secured servers.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/cs2/cs2-ubuntu.sh
chmod +x cs2-ubuntu.sh
sudo bash cs2-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for GSLT token, server name, max players, and map
- Starts the game server
- Runs a health check

---

## Connect

| | |
|---|---|
| **In-game** | CS2 console: `connect SERVER_IP:27015` |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `27015` | TCP + UDP | Game + RCON |
| `27020` | UDP | SourceTV / relay |

---

## Hardware Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 2 GB | 4 GB |
| CPU | 4 cores | 8 cores |
| Disk | 20 GB | 30 GB |

---

## Game Modes

Set `CS2_GAMETYPE` and `CS2_GAMEMODE` in `docker-compose.yml`:

| Mode | Type | Description |
|------|------|-------------|
| 0 | 1 | Competitive |
| 0 | 0 | Casual |
| 1 | 0 | Arms Race |
| 1 | 2 | Deathmatch |

---

## Features

- VAC anti-cheat support via GSLT token
- RCON remote administration
- Configurable game type and mode
- Map group rotation support
- Server data persisted in `./data/`

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/cs2/` | All service data and configuration |
| `/root/docker/cs2/data/` | Game files and configs |

---

## Management

```bash
# Follow logs
docker logs -f cs2

# Stop
cd /root/docker/cs2 && docker compose down

# Start
cd /root/docker/cs2 && docker compose up -d

# Update to latest image
cd /root/docker/cs2 && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 27015/tcp+udp, 27020/udp open in firewall
- **Steam GSLT Token** required (free at Steam game server management page)

---

## Notes

- First start downloads ~15 GB — takes 10–30 minutes
- CS2 is free to play — clients do not need to purchase it
- GSLT tokens are free but require a Steam account with CS2 owned
- Server configs in `./data/game/csgo/cfg/`

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
