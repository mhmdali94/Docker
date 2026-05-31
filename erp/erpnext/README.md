# ERPNext — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

100% open-source ERP covering Accounting, HR, Manufacturing, CRM, Projects, Buying, Selling, and Stock.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is ERPNext?

ERPNext is a comprehensive open-source ERP built on the Frappe framework. It covers the full business lifecycle: accounting, inventory, purchasing, sales, CRM, HR and payroll, manufacturing, project management, and more. Widely used by SMEs and supported by a large global community. Supports Arabic (RTL) and multilingual operation.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/erp/erpnext/erpnext-ubuntu.sh
chmod +x erpnext-ubuntu.sh
sudo bash erpnext-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:8119` |
| **Username** | `administrator` |
| **Password** | Auto-generated (shown at install) |

> Replace `SERVER_IP` with your server's IP address. First startup takes 5-10 minutes for initialization.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8119` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/erpnext/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f erpnext

# Stop the service
cd /root/docker/erpnext && docker compose down

# Start the service
cd /root/docker/erpnext && docker compose up -d

# Update to latest image
cd /root/docker/erpnext && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Minimum 4 GB RAM recommended
- Ports open in firewall: 8119/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
