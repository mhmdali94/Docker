# Mealie — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Mealie is a self-hosted recipe manager and meal planner that imports recipes from any URL, organizes by tags, plans weekly meals, and auto-generates shopping lists.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Mealie?

Mealie is a modern recipe management application with a clean UI. It can automatically scrape recipes from thousands of websites, supports meal planning, generates grocery lists, tracks nutritional information, and provides multi-user support with household sharing. It also exposes a REST API for integrations.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/mealie/mealie-ubuntu.sh
chmod +x mealie-ubuntu.sh
sudo bash mealie-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Starts the Mealie container
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:9925` |
| **Email** | `admin@mealie.local` |
| **Password** | `MyPassword` |

> Replace `SERVER_IP` with your server's actual IP address.
> **Change the default password immediately after first login.**

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `9925` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/mealie/` | All service data and configuration |
| `/root/docker/mealie/data/` | Recipes, images, and database |

---

## Management

```bash
# Follow logs
docker logs -f mealie

# Stop
cd /root/docker/mealie && docker compose down

# Start
cd /root/docker/mealie && docker compose up -d

# Update to latest image
cd /root/docker/mealie && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 9925/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
