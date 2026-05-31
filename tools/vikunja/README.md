# Vikunja — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Vikunja is an open-source task manager with lists, Kanban boards, Gantt charts, and team collaboration — a self-hosted Todoist alternative.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Vikunja?

Vikunja is a feature-rich productivity app for managing tasks and projects. It supports list views, Kanban boards, Gantt charts, table views, and team namespaces. Tasks can have due dates, reminders, labels, assignees, attachments, and repeating intervals. It includes built-in CaldAV support for calendar integration and provides a REST API for automation and third-party clients.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/vikunja/vikunja-ubuntu.sh
chmod +x vikunja-ubuntu.sh
sudo bash vikunja-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure database password and JWT secret
- Starts Vikunja and MariaDB 10.11
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:3456` |
| **Setup** | First registered user becomes admin |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3456` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/vikunja/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f vikunja

# Stop
cd /root/docker/vikunja && docker compose down

# Start
cd /root/docker/vikunja && docker compose up -d

# Update to latest image
cd /root/docker/vikunja && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 3456/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
