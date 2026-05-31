# Twenty — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Twenty is an open-source CRM for managing companies, contacts, deals, and custom data objects — a modern Salesforce alternative.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Twenty?

Twenty is a next-generation CRM built with a modern React frontend and GraphQL API. It provides a flexible data model with custom objects, views, and filters — allowing teams to adapt the CRM to their workflow rather than the other way around. It supports Kanban boards, list views, pipeline management, and rich integrations. Twenty is fully open-source and designed to compete with Salesforce and HubSpot.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/twenty/twenty-ubuntu.sh
chmod +x twenty-ubuntu.sh
sudo bash twenty-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure database password and app secret
- Starts Twenty, PostgreSQL 15, and Redis 7
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:3300` |
| **Setup** | Register workspace on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3300` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/twenty/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f twenty

# Stop
cd /root/docker/twenty && docker compose down

# Start
cd /root/docker/twenty && docker compose up -d

# Update to latest image
cd /root/docker/twenty && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 3300/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
