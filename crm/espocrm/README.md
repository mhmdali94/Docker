# EspoCRM — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Modern open-source CRM with a clean UI covering leads, contacts, accounts, opportunities, activities, and workflow automation.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is EspoCRM?

EspoCRM is a modern, lightweight open-source CRM that covers the full sales lifecycle: leads, contacts, accounts, opportunities, activities, email client, calendar, and workflow automation. It supports Arabic (RTL) and 30+ languages, offers a REST API, and has an extension marketplace for VoIP, email marketing, and customer portal features.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/crm/espocrm/espocrm-ubuntu.sh
chmod +x espocrm-ubuntu.sh
sudo bash espocrm-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:8130` |
| **Username** | `admin` |
| **Password** | Auto-generated (shown at install) |

> Replace `SERVER_IP` with your server's IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8130` | TCP | Web UI / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/espocrm/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f espocrm

# Stop the service
cd /root/docker/espocrm && docker compose down

# Start the service
cd /root/docker/espocrm && docker compose up -d

# Update to latest image
cd /root/docker/espocrm && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 8130/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
