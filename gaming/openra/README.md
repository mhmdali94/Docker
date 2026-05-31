# OpenRA Server — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

OpenRA is an open-source reimplementation of classic Command & Conquer real-time strategy games. Completely free. Powered by `rmoriz/openra`.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is OpenRA?

OpenRA recreates the classic real-time strategy games Red Alert, Tiberian Dawn (Command & Conquer), and Dune 2000 with modern features, improved networking, and mod support. No original game files are required — all assets are open-source. Servers automatically advertise to the OpenRA master server for public visibility.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/openra/openra-ubuntu.sh
chmod +x openra-ubuntu.sh
sudo bash openra-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for game mod, server name, and max players
- Starts the game server
- Runs a health check

---

## Connect

| | |
|---|---|
| **In-game** | Multiplayer → Join Game → Direct Connect → `SERVER_IP:1234` |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `1234` | TCP | Game port |

---

## Hardware Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 256 MB | 512 MB |
| CPU | 1 core | 1 core |
| Disk | 500 MB | 1 GB |

---

## Available Games (Mods)

| Mod | Game |
|-----|------|
| `ra` | Red Alert (default) |
| `cnc` | Tiberian Dawn (C&C) |
| `d2k` | Dune 2000 |

---

## Features

- Advertises to OpenRA master server automatically
- Supports all three classic game mods
- No original game files required — assets are open-source
- Server data persisted in `./data/`

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/openra/` | All service data and configuration |
| `/root/docker/openra/data/` | Game data |

---

## Management

```bash
# Follow logs
docker logs -f openra

# Stop
cd /root/docker/openra && docker compose down

# Start
cd /root/docker/openra && docker compose up -d

# Update to latest image
cd /root/docker/openra && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 1234/tcp open in firewall

---

## Notes

- OpenRA is completely free — no purchase required
- Change game mod: edit `OPENRA_MOD` in `docker-compose.yml` and restart
- Server shows up in OpenRA's multiplayer lobby automatically

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
