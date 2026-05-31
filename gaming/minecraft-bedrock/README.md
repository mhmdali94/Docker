# Minecraft Bedrock Edition Server — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Minecraft Bedrock Edition is a cross-platform server supporting mobile (PE), Windows 10/11, Xbox, Switch, and PlayStation. Powered by `itzg/minecraft-bedrock-server`.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Minecraft Bedrock Edition?

Minecraft Bedrock Edition is the cross-platform version of Minecraft that runs on mobile devices, Windows 10/11, Xbox, Nintendo Switch, and PlayStation. The Bedrock Dedicated Server (BDS) allows all these platforms to connect to the same server. It supports Xbox Live authentication, marketplace content, and add-ons (but not Java Edition mods/plugins).

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/minecraft-bedrock/minecraft-bedrock-ubuntu.sh
chmod +x minecraft-bedrock-ubuntu.sh
sudo bash minecraft-bedrock-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for server name, gamemode, difficulty, and max players
- Starts the game server
- Runs a health check

---

## Connect

| | |
|---|---|
| **In-game** | Servers → Add Server → `SERVER_IP:19132` |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `19132` | UDP | Game port (IPv4) |
| `19133` | UDP | Game port (IPv6) |

---

## Hardware Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 1 GB | 2 GB |
| CPU | 2 cores | 4 cores |
| Disk | 2 GB | 5 GB |

---

## Cross-Platform Support

Works with:
- Android / iOS (Minecraft PE)
- Windows 10 / 11 Edition
- Xbox One / Series
- Nintendo Switch
- PlayStation 4 / 5

---

## Features

- Auto-downloads latest Bedrock server binary
- Xbox Live authentication (online mode)
- Configurable game mode and difficulty
- World data persisted in `./data/worlds/`

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/minecraft-bedrock/` | All service data and configuration |
| `/root/docker/minecraft-bedrock/data/worlds/` | World saves |
| `/root/docker/minecraft-bedrock/data/server.properties` | Server configuration |

---

## Management

```bash
# Follow logs
docker logs -f minecraft-bedrock

# Stop
cd /root/docker/minecraft-bedrock && docker compose down

# Start
cd /root/docker/minecraft-bedrock && docker compose up -d

# Update to latest image
cd /root/docker/minecraft-bedrock && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 19132, 19133/udp open in firewall

---

## Notes

- Bedrock dedicated server is free — clients need the game purchased
- `ONLINE_MODE: "false"` disables Xbox auth (allows LAN/unofficial clients)
- Server properties at `./data/server.properties`
- Cannot run Java Edition plugins/mods — use the Java server for those

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
