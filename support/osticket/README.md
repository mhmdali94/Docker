# osTicket — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

osTicket is an open-source customer support ticketing system that accepts requests via web form or email, assigns them to agents, and tracks resolution.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is osTicket?

osTicket is a widely deployed, battle-tested helpdesk and ticketing platform. It supports multiple departments, email piping, canned responses, SLA plans, reports, and a customer-facing portal. It is suitable for IT support, customer service, and internal helpdesks.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/support/osticket/osticket-ubuntu.sh
chmod +x osticket-ubuntu.sh
sudo bash osticket-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure credentials
- Starts osTicket and MySQL
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:8088` |
| **Admin Panel** | `http://SERVER_IP:8088/scp` |
| **Admin Email** | `admin@osticket.local` |
| **Admin Password** | Auto-generated during install (displayed in terminal) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8088` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/osticket/` | All service data and configuration |
| `/root/docker/osticket/data/` | Application data |
| `/root/docker/osticket/mysql/` | Database storage |

---

## Management

```bash
# Follow logs
docker logs -f osticket

# Stop
cd /root/docker/osticket && docker compose down

# Start
cd /root/docker/osticket && docker compose up -d

# Update to latest image
cd /root/docker/osticket && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8088/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
