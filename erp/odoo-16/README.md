# Odoo 16 — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Odoo 16 is a comprehensive open-source ERP platform covering CRM, Sales, Inventory, Accounting, HR, Manufacturing, Point of Sale, and E-commerce.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Odoo 16?

Odoo is a suite of fully integrated business applications that covers the entire company lifecycle. Version 16 brings a redesigned interface, improved performance, and enhanced modules for accounting, inventory, manufacturing, and e-commerce. It is one of the most popular open-source ERP platforms, used by businesses of all sizes worldwide.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/erp/odoo-16/odoo16-ubuntu.sh
chmod +x odoo16-ubuntu.sh
sudo bash odoo16-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:8016` |
| **Database Manager** | `http://SERVER_IP:8016/web/database/manager` |
| **Master Password** | Auto-generated during install (displayed in terminal) |
| **Username** | Set when creating the first database |
| **Password** | Set when creating the first database |

> Replace `SERVER_IP` with your server's actual IP address. Create your first database via the Database Manager URL using the master password shown at install.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8016` | TCP | Web UI / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/odoo16/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f odoo16

# Stop
cd /root/docker/odoo16 && docker compose down

# Start
cd /root/docker/odoo16 && docker compose up -d

# Update to latest image
cd /root/docker/odoo16 && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8016/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
