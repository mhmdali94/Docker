# Barotrauma Server — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Barotrauma is a 2D co-op submarine survival horror game set in Europa's ocean. Powered by `linuxserver/barotrauma`.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Barotrauma?

Barotrauma is a cooperative submarine simulation where crew members navigate the treacherous depths of Jupiter's moon Europa. Players manage submarine systems, fight alien creatures, complete missions, and deal with traitors in their midst. The dedicated server supports campaign and mission modes with a karma system to discourage griefing.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/barotrauma/barotrauma-ubuntu.sh
chmod +x barotrauma-ubuntu.sh
sudo bash barotrauma-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for server name, password, and max players
- Starts the game server
- Runs a health check

---

## Connect

| | |
|---|---|
| **In-game** | Play → Join Server → filter by name or Direct Connect → `SERVER_IP:27015` |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `27015` | UDP | Game port |
| `27016` | UDP | Steam query |

---

## Hardware Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 2 GB | 4 GB |
| CPU | 2 cores | 4 cores |
| Disk | 3 GB | 6 GB |

---

## Features

- Karma system enabled (punishes griefers)
- Spectating allowed
- Auto-restart on crash
- Optional server password
- Save data and configs persisted in `./data/`

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/barotrauma/` | All service data and configuration |
| `/root/docker/barotrauma/data/` | Saves and server settings |

---

## Management

```bash
# Follow logs
docker logs -f barotrauma

# Stop
cd /root/docker/barotrauma && docker compose down

# Start
cd /root/docker/barotrauma && docker compose up -d

# Update to latest image
cd /root/docker/barotrauma && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 27015, 27016/udp open in firewall

---

## Notes

- Barotrauma must be purchased — dedicated server is free
- Server config at `./data/serversettings.xml`
- Campaign saves at `./data/`
- Admin access in-game: type owner key in the console

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
