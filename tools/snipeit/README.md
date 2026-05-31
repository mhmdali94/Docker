# Snipe-IT — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Snipe-IT is an open-source IT asset management system for tracking laptops, servers, licenses, accessories, and consumables.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Snipe-IT?

Snipe-IT provides a complete IT asset lifecycle management platform. Track who has what asset, where it is located, and when it is due back. It supports QR/barcode label generation, check-in/check-out workflows, software license seat management, depreciation tracking, maintenance scheduling, and email notifications. It includes a REST API for integrations and supports LDAP/Active Directory for authentication.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/snipeit/snipeit-ubuntu.sh
chmod +x snipeit-ubuntu.sh
sudo bash snipeit-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure database password and app key
- Starts Snipe-IT and MySQL 8.0
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:8002` |
| **Setup** | Setup wizard on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8002` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/snipeit/` | All service data and configuration |
| `/root/docker/snipeit/data/` | Config and uploads |
| `/root/docker/snipeit/mysql/` | Database storage |

---

## Management

```bash
# Follow logs
docker logs -f snipeit

# Stop
cd /root/docker/snipeit && docker compose down

# Start
cd /root/docker/snipeit && docker compose up -d

# Update to latest image
cd /root/docker/snipeit && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8002/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
