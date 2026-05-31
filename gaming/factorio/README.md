# Factorio Server — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Factorio is an automation and factory-building multiplayer game. Powered by `factoriotools/factorio` — the official community-maintained Docker image.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Factorio?

Factorio is a game about building and managing automated factories on an alien planet. Players mine resources, design production lines, research technologies, and defend against native wildlife. The dedicated server supports multiplayer co-op with mod support, autosave, and RCON for remote administration.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/factorio/factorio-ubuntu.sh
chmod +x factorio-ubuntu.sh
sudo bash factorio-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for server name, description, and max players
- Starts the game server
- Runs a health check

---

## Connect

| | |
|---|---|
| **In-game** | Multiplayer → Browse Public Games or Connect to Address → `SERVER_IP:34197` |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `34197` | UDP | Game port |
| `27015` | TCP | RCON |

---

## Hardware Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 1 GB | 2–4 GB |
| CPU | 2 cores | 4 cores |
| Disk | 2 GB | 5 GB |

---

## Features

- Auto-generates new save on first start
- 10-minute autosave with 5 slots
- RCON remote console
- Mod support via `./mods/` directory
- Save files persisted in `./saves/`

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/factorio/` | All service data and configuration |
| `/root/docker/factorio/saves/` | World saves |
| `/root/docker/factorio/config/` | Server settings |

---

## Management

```bash
# Follow logs
docker logs -f factorio

# Stop
cd /root/docker/factorio && docker compose down

# Start
cd /root/docker/factorio && docker compose up -d

# Update to latest image
cd /root/docker/factorio && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 34197/udp and 27015/tcp open in firewall

---

## Notes

- Factorio must be purchased — dedicated server is free
- Drop mods (`.zip` files) in `./mods/` and restart
- Server settings in `./config/server-settings.json`
- Admins-only commands by default (`allow_commands: admins-only`)

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
