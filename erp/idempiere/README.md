# iDempiere — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Enterprise-grade open-source ERP and CRM based on the ADempiere/Compiere codebase with a plugin architecture.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is iDempiere?

iDempiere is a mature, enterprise-grade open-source ERP system built on OSGi/Eclipse RCP and derived from the Compiere/ADempiere codebase. It covers accounting, supply chain, purchasing, sales, manufacturing, HR, and business intelligence through an extensible plugin architecture. Used in large-scale deployments across manufacturing, distribution, and service industries.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/erp/idempiere/idempiere-ubuntu.sh
chmod +x idempiere-ubuntu.sh
sudo bash idempiere-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:8121/webui/` |
| **Username** | `GardenAdmin` |
| **Password** | `GardenAdmin` (change immediately after first login) |

> Replace `SERVER_IP` with your server's IP address. First startup takes 3-5 minutes. Default login uses the Garden World demo company.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8121` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/idempiere/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f idempiere

# Stop the service
cd /root/docker/idempiere && docker compose down

# Start the service
cd /root/docker/idempiere && docker compose up -d

# Update to latest image
cd /root/docker/idempiere && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Minimum 2 GB RAM
- Ports open in firewall: 8121/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
