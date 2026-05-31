# OpenEMR — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

The world's most widely deployed open-source electronic health records and medical practice management system.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is OpenEMR?

OpenEMR is a comprehensive open-source EHR and practice management system covering patient scheduling, clinical documentation, e-prescribing, billing, and reporting. It supports 30+ languages including Arabic (RTL), HIPAA compliance tools, and an optional patient portal. Used by clinics and hospitals in over 100 countries. First startup takes 3–5 minutes while the database initializes.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/clinic/openemr/openemr-ubuntu.sh
chmod +x openemr-ubuntu.sh
sudo bash openemr-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure database and admin credentials
- Starts the service stack (OpenEMR + MariaDB)
- Runs a health check (allow 3–5 minutes for DB initialization)

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:8124` |
| **Username** | `admin` |
| **Password** | Auto-generated during install (displayed in terminal) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8124` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/openemr/` | All service data and configuration |
| `/root/docker/openemr/sites/` | OpenEMR site data |
| `/root/docker/openemr/logs/` | Application logs |

---

## Management

```bash
# Follow logs
docker logs -f openemr

# Stop
cd /root/docker/openemr && docker compose down

# Start
cd /root/docker/openemr && docker compose up -d

# Update to latest image
cd /root/docker/openemr && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8124/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
