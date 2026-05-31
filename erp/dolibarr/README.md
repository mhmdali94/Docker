# Dolibarr — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Lightweight open-source ERP and CRM for small and medium businesses covering invoicing, accounting, stock, HR, and projects.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Dolibarr?

Dolibarr is a lightweight, modular open-source ERP and CRM designed for small and medium businesses. It covers invoicing, accounting, stock management, HR, project management, point of sale, and e-commerce integration. Activate only the modules you need through a simple setup interface. Supports Arabic and 30+ other languages.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/erp/dolibarr/dolibarr-ubuntu.sh
chmod +x dolibarr-ubuntu.sh
sudo bash dolibarr-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:8120` |
| **Username** | `admin` |
| **Password** | Auto-generated (shown at install) |

> Replace `SERVER_IP` with your server's IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8120` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/dolibarr/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f dolibarr

# Stop the service
cd /root/docker/dolibarr && docker compose down

# Start the service
cd /root/docker/dolibarr && docker compose up -d

# Update to latest image
cd /root/docker/dolibarr && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 8120/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
