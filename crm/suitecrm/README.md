# SuiteCRM — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

The world's most popular open-source CRM — a full fork of SugarCRM covering leads, opportunities, contacts, accounts, campaigns, cases, and reporting.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is SuiteCRM?

SuiteCRM is a comprehensive open-source CRM platform forked from SugarCRM. It covers the full sales and service lifecycle: leads, opportunities, accounts, contacts, campaigns, cases, contracts, invoices, and advanced reporting. Supports module customization through a Module Loader, workflow automation, and a REST API.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/crm/suitecrm/suitecrm-ubuntu.sh
chmod +x suitecrm-ubuntu.sh
sudo bash suitecrm-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:8129` |
| **Username** | `admin` |
| **Password** | Auto-generated (shown at install) |

> Replace `SERVER_IP` with your server's IP address. First startup takes 3-5 minutes for database initialization.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8129` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/suitecrm/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f suitecrm

# Stop the service
cd /root/docker/suitecrm && docker compose down

# Start the service
cd /root/docker/suitecrm && docker compose up -d

# Update to latest image
cd /root/docker/suitecrm && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 8129/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
