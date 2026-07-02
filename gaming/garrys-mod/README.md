# Garry's Mod Server — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Garry's Mod is a sandbox physics game with a massive modding ecosystem. Powered by `ceifa/garrysmod`.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Garry's Mod?

Garry's Mod is a physics sandbox that allows players to build, experiment, and create using the Source engine. It has a massive modding community with popular game modes like DarkRP, Trouble in Terrorist Town (TTT), Prop Hunt, and more. The dedicated server supports Steam Workshop collections, Lua addons, and RCON administration.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/garrys-mod/garrysmod-ubuntu.sh
chmod +x garrysmod-ubuntu.sh
sudo bash garrysmod-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for server name, gamemode, map, and max players
- Starts the game server
- Runs a health check

---

## Connect

| | |
|---|---|
| **In-game** | GMod console: `connect SERVER_IP:27015` or via Steam Server Browser |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `27015` | TCP + UDP | Game + RCON |
| `27005` | UDP | Client port |

---

## Hardware Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 1 GB | 2–4 GB |
| CPU | 2 cores | 4 cores |
| Disk | 8 GB | 15 GB |

---

## Popular Game Modes

| Mode | Description |
|------|-------------|
| `sandbox` | Default — build and experiment |
| `terrortown` | TTT — social deduction |
| `darkrp` | RP with economy |
| `prophunt` | Hide and seek |

---

## Features

- Steam Workshop collection support (`SRCDS_WORKSHOPCOLLECTION`)
- RCON remote administration
- Lua addon support
- Server data persisted in `./data/`

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/garrysmod/` | All service data and configuration |
| `/root/docker/garrysmod/data/` | Game data and addons |

---

## Management

```bash
# Follow logs
docker logs -f garrysmod

# Stop
cd /root/docker/garrysmod && docker compose down

# Start
cd /root/docker/garrysmod && docker compose up -d

# Update to latest image
cd /root/docker/garrysmod && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 27015/tcp+udp, 27005/udp open in firewall

---

## Notes

- First start downloads ~5 GB — takes 5–15 minutes
- Garry's Mod must be purchased — dedicated server is free
- Add Workshop collection ID to `SRCDS_WORKSHOPCOLLECTION` in `docker-compose.yml`
- Lua addons: place in `./data/garrysmod/addons/`

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
