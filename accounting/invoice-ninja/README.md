# Invoice Ninja — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Professional invoicing, billing, and client management platform for freelancers and small businesses.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Invoice Ninja?

Invoice Ninja is a feature-rich open-source invoicing platform that handles client management, quotes, invoices, recurring billing, time tracking, and expense management. It supports multiple payment gateways, multi-currency billing, and a white-label client portal where customers can view and pay invoices directly.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/accounting/invoice-ninja/invoice-ninja-ubuntu.sh
chmod +x invoice-ninja-ubuntu.sh
sudo bash invoice-ninja-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure credentials and app key
- Starts the service stack (nginx, PHP-FPM app, MariaDB)
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:8128` |
| **Email** | `admin@example.com` |
| **Password** | Auto-generated during install (displayed in terminal) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8128` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/invoice-ninja/` | All service data and configuration |
| `/root/docker/invoice-ninja/db/` | MariaDB database files |

---

## Management

```bash
# Follow logs
docker logs -f invoiceninja

# Stop
cd /root/docker/invoice-ninja && docker compose down

# Start
cd /root/docker/invoice-ninja && docker compose up -d

# Update to latest image
cd /root/docker/invoice-ninja && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8128/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
