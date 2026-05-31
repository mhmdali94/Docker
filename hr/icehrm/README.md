# IceHRM — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

IceHRM is an open-source human resource management system that covers employee profiles, leave management, attendance tracking, payroll, and document management.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is IceHRM?

IceHRM is a lightweight HR platform suitable for small and medium-sized businesses. It provides employee self-service, time and attendance tracking, leave workflows, payroll support, and document storage — all in a single, easy-to-use web interface.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/hr/icehrm/icehrm-ubuntu.sh
chmod +x icehrm-ubuntu.sh
sudo bash icehrm-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:8126` |
| **Username** | `admin` |
| **Password** | Auto-generated during install (displayed in terminal) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8126` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/icehrm/` | All service data and configuration |
| `/root/docker/icehrm/db/` | MySQL database |
| `/root/docker/icehrm/data/` | Application data and uploads |

---

## Management

```bash
# Follow logs
docker logs -f icehrm

# Stop
cd /root/docker/icehrm && docker compose down

# Start
cd /root/docker/icehrm && docker compose up -d

# Update to latest image
cd /root/docker/icehrm && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8126/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
