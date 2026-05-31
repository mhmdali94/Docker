# Akaunting — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Free and open-source accounting software for invoicing, expenses, bank reconciliation, tax reports, and multi-currency transactions.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Akaunting?

Akaunting is a modern, web-based accounting platform built for small businesses and freelancers. It covers double-entry accounting, invoicing, expense tracking, multi-currency support, and tax reporting. A marketplace of free and paid add-ons extends it with payroll, inventory, and advanced analytics.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/accounting/akaunting/akaunting-ubuntu.sh
chmod +x akaunting-ubuntu.sh
sudo bash akaunting-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure database credentials
- Starts the service stack (Akaunting + MySQL)
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:8127` |
| **Username** | Created on first visit (setup wizard) |
| **Password** | Created on first visit (setup wizard) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8127` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/akaunting/` | All service data and configuration |
| `/root/docker/akaunting/storage/` | Application storage |

---

## Management

```bash
# Follow logs
docker logs -f akaunting

# Stop
cd /root/docker/akaunting && docker compose down

# Start
cd /root/docker/akaunting && docker compose up -d

# Update to latest image
cd /root/docker/akaunting && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8127/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
