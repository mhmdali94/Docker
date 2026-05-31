# Kimai — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Kimai is an open-source time tracking application for freelancers and teams to track time on projects and clients, generate invoices, and export reports.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Kimai?

Kimai is a professional time tracking tool that supports multiple users, projects, clients, and activities. It generates detailed reports, supports invoice creation, exports to various formats, and provides REST API access. It is suitable for freelancers billing by the hour and teams needing accurate project time tracking.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/kimai/kimai-ubuntu.sh
chmod +x kimai-ubuntu.sh
sudo bash kimai-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure credentials
- Starts Kimai and MySQL
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:8001` |
| **Email** | Set during install (default: `admin@kimai.local`) |
| **Password** | Auto-generated during install (displayed in terminal) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8001` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/kimai/` | All service data and configuration |
| `/root/docker/kimai/data/` | Application data |
| `/root/docker/kimai/plugins/` | Installed plugins |
| `/root/docker/kimai/mysql/` | Database storage |

---

## Management

```bash
# Follow logs
docker logs -f kimai

# Stop
cd /root/docker/kimai && docker compose down

# Start
cd /root/docker/kimai && docker compose up -d

# Update to latest image
cd /root/docker/kimai && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8001/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
