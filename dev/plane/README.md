# Plane — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Open-source project management tool — track issues, plan sprints, manage cycles, and build roadmaps. A self-hosted Linear and Jira alternative.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Plane?

Plane is an open-source project management platform designed for software teams. It provides issue tracking, sprint cycles, roadmaps, analytics, and workspace collaboration. The interface is clean and fast, inspired by Linear, with support for multiple workspaces and team members.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/plane/plane-ubuntu.sh
chmod +x plane-ubuntu.sh
sudo bash plane-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:8091` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8091` | TCP | Web UI / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/plane/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f plane-web

# Stop the service
cd /root/docker/plane && docker compose down

# Start the service
cd /root/docker/plane && docker compose up -d

# Update to latest image
cd /root/docker/plane && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 8091/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
