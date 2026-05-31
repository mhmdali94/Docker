# Firefly III — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Firefly III is a self-hosted personal finance manager with double-entry bookkeeping, budgets, bills, and detailed financial reports.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Firefly III?

Firefly III is a free, open-source personal finance tool that helps you track income, expenses, budgets, and savings goals. It uses double-entry bookkeeping for accuracy, supports multiple currencies and accounts, generates detailed charts and reports, and can import transactions from banks via CSV or automated rules.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/firefly-iii/firefly-iii-ubuntu.sh
chmod +x firefly-iii-ubuntu.sh
sudo bash firefly-iii-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates a secure app key and database credentials
- Starts Firefly III and MariaDB
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:8095` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8095` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/firefly-iii/` | All service data and configuration |
| `/root/docker/firefly-iii/upload/` | Uploaded receipts and attachments |
| `/root/docker/firefly-iii/mysql/` | Database storage |

---

## Management

```bash
# Follow logs
docker logs -f firefly

# Stop
cd /root/docker/firefly-iii && docker compose down

# Start
cd /root/docker/firefly-iii && docker compose up -d

# Update to latest image
cd /root/docker/firefly-iii && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8095/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
