# OrangeHRM — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

OrangeHRM is an open-source human resource management system covering employee records, leave management, time tracking, performance reviews, recruitment, and payroll.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is OrangeHRM?

OrangeHRM is a feature-rich HR platform used by organizations worldwide. It provides employee self-service, leave and time-off workflows, performance appraisals, a recruitment module, and detailed HR reporting — all through a polished web interface.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/hr/orangehrm/orangehrm-ubuntu.sh
chmod +x orangehrm-ubuntu.sh
sudo bash orangehrm-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:8125` |
| **Username** | `admin` |
| **Password** | Auto-generated during install (displayed in terminal) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8125` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/orangehrm/` | All service data and configuration |
| `/root/docker/orangehrm/db/` | MariaDB database |
| `/root/docker/orangehrm/data/` | Application uploads and configuration |

---

## Management

```bash
# Follow logs
docker logs -f orangehrm

# Stop
cd /root/docker/orangehrm && docker compose down

# Start
cd /root/docker/orangehrm && docker compose up -d

# Update to latest image
cd /root/docker/orangehrm && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8125/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
