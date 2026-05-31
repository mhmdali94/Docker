# Rust Game Server — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Rust is a hardcore survival multiplayer game with procedurally generated maps. Powered by `linuxserver/rust`.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Rust?

Rust is a competitive survival game where players start naked on a procedurally generated island and must gather resources, build bases, craft weapons, and form alliances to survive against other players and the environment. The dedicated server supports configurable map size and seed, RCON web administration, Oxide plugin support, and the Rust+ companion app.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/rust/rust-ubuntu.sh
chmod +x rust-ubuntu.sh
sudo bash rust-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for GSLT token, server name, map size, and max players
- Generates random map seed
- Starts the game server
- Runs a health check

---

## Connect

| | |
|---|---|
| **In-game** | F1 → `client.connect SERVER_IP:28015` |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `28015` | TCP + UDP | Game port |
| `28016` | TCP | RCON WebUI |
| `28017` | UDP | Steam query |
| `28082` | TCP | Rust+ companion app |

---

## Hardware Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 8 GB | 16 GB |
| CPU | 4 cores | 8+ cores |
| Disk | 15 GB | 30 GB |

---

## Features

- Random map seed generated at install time
- Configurable map size (1000–6000)
- RCON web interface for remote administration
- Oxide plugin support (drop plugins in `./oxide/plugins/`)
- Server data persisted in `./data/`

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/rust/` | All service data and configuration |
| `/root/docker/rust/data/` | Game data and saves |
| `/root/docker/rust/oxide/plugins/` | Oxide mods |

---

## Management

```bash
# Follow logs
docker logs -f rust

# Stop
cd /root/docker/rust && docker compose down

# Start
cd /root/docker/rust && docker compose up -d

# Update to latest image
cd /root/docker/rust && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 28015/tcp+udp, 28016, 28082/tcp, 28017/udp open in firewall
- **Steam GSLT Token** required (free, App ID `252490`)

---

## Notes

- First start downloads ~7 GB — takes 15–30 minutes
- Rust must be purchased — dedicated server is free
- Map wipes: restart container with a new `+server.seed` value
- RCON WebUI available at `http://SERVER_IP:28016`
- Oxide mods: place `.cs` or `.dll` files in `./oxide/plugins/`

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
