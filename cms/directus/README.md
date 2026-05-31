# Directus — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Real-time headless CMS and data platform that wraps any SQL database with an instant REST and GraphQL API.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Directus?

Directus is an open-source headless CMS and data platform that sits on top of any SQL database and instantly provides REST and GraphQL APIs alongside a no-code data studio. It supports real-time subscriptions, automation flows, webhooks, role-based access control, and file management — without changing your database schema.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/cms/directus/directus-ubuntu.sh
chmod +x directus-ubuntu.sh
sudo bash directus-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure credentials and secret
- Starts the service stack (Directus + PostgreSQL + Redis)
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:8055` |
| **Email** | Set during install (default: `admin@directus.local`) |
| **Password** | Auto-generated during install (displayed in terminal) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8055` | TCP | Web UI / REST API / GraphQL |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/directus/` | All service data and configuration |
| `/root/docker/directus/uploads/` | Uploaded media files |
| `/root/docker/directus/extensions/` | Custom extensions |

---

## Management

```bash
# Follow logs
docker logs -f directus

# Stop
cd /root/docker/directus && docker compose down

# Start
cd /root/docker/directus && docker compose up -d

# Update to latest image
cd /root/docker/directus && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8055/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
