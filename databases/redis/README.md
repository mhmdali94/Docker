# Redis — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

In-memory data store used as a database, cache, and message broker — ultra-fast key-value storage.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Redis?

Redis is an open-source in-memory data structure store that can be used as a database, cache, message broker, and streaming engine. It supports strings, hashes, lists, sets, sorted sets, bitmaps, and streams. Widely used as the caching and session layer for web applications and as the backend for queue-based systems.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/databases/redis/redis-ubuntu.sh
chmod +x redis-ubuntu.sh
sudo bash redis-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure credentials
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Database Port** | `SERVER_IP:6379` |
| **Password** | Auto-generated (shown at install) |

> Replace `SERVER_IP` with your server's IP address. Connect: `redis-cli -h SERVER_IP -p 6379 -a PASSWORD`

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `6379` | TCP | Redis protocol |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/redis/` | All service data and configuration |

---

## Management

```bash
# Connect via Docker
docker exec -it redis redis-cli -a PASSWORD

# Follow logs
docker logs -f redis

# Stop the service
cd /root/docker/redis && docker compose down

# Start the service
cd /root/docker/redis && docker compose up -d

# Update to latest image
cd /root/docker/redis && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 6379/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
