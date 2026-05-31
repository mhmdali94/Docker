# GNU Health — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Free and open-source health and hospital information system covering patient management, EHR, laboratory, pharmacy, and epidemiology.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is GNU Health?

GNU Health is a comprehensive open-source Health and Hospital Information System (HIS) built on the Tryton platform. It covers patient registration, electronic health records, clinical workflows, laboratory management, pharmacy, and public health epidemiology. Widely adopted by hospitals and clinics in developing countries and recognized by the World Health Organization.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/clinic/gnu-health/gnu-health-ubuntu.sh
chmod +x gnu-health-ubuntu.sh
sudo bash gnu-health-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure database and admin credentials
- Starts the service stack (GNU Health + Tryton Web + PostgreSQL)
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI (Tryton SAO)** | `http://SERVER_IP:8123` |
| **Tryton Server (desktop client)** | `SERVER_IP:8000` |
| **Username** | `admin` |
| **Password** | Auto-generated during install (displayed in terminal) |

> Replace `SERVER_IP` with your server's actual IP address. Select the `gnuhealth` database when connecting.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8123` | TCP | Web UI (Tryton SAO client) |
| `8000` | TCP | GNU Health / Tryton server (desktop client) |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/gnu-health/` | All service data and configuration |
| `/root/docker/gnu-health/data/` | Application data |

---

## Management

```bash
# Follow logs
docker logs -f gnuhealth

# Stop
cd /root/docker/gnu-health && docker compose down

# Start
cd /root/docker/gnu-health && docker compose up -d

# Update to latest image
cd /root/docker/gnu-health && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8123/tcp open in firewall
- Port 8000/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
