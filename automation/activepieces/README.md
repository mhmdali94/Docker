# Activepieces — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Open-source workflow automation platform with a no-code builder and 200+ app integrations — a self-hosted Make alternative.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Activepieces?

Activepieces is an open-source automation platform that lets you build workflows connecting apps, services, and APIs without writing code. It includes 200+ built-in integrations, a visual flow builder, webhook triggers, scheduled runs, and code steps for custom logic. A self-hosted alternative to Make (formerly Integromat) and Zapier.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/automation/activepieces/activepieces-ubuntu.sh
chmod +x activepieces-ubuntu.sh
sudo bash activepieces-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure credentials, JWT secret, and encryption key
- Starts the service stack (Activepieces + PostgreSQL + Redis)
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:8099` |
| **Username** | Registered on first visit |
| **Password** | Registered on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8099` | TCP | Web UI / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/activepieces/` | All service data and configuration |
| `/root/docker/activepieces/postgres/` | PostgreSQL database files |

---

## Management

```bash
# Follow logs
docker logs -f activepieces

# Stop
cd /root/docker/activepieces && docker compose down

# Start
cd /root/docker/activepieces && docker compose up -d

# Update to latest image
cd /root/docker/activepieces && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8099/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
