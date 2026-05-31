# OpenMRS — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Open-source electronic medical records system used by hospitals and clinics in over 40 countries.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is OpenMRS?

OpenMRS is a modular, open-source electronic medical records platform designed for resource-constrained environments. It provides patient registration, visit tracking, clinical data entry, order management, and reporting. The platform powers healthcare delivery in over 40 countries through a large ecosystem of community-built modules. First startup takes 5–10 minutes while the database schema initializes.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/clinic/openmrs/openmrs-ubuntu.sh
chmod +x openmrs-ubuntu.sh
sudo bash openmrs-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure database credentials
- Starts the service stack (OpenMRS + MySQL)
- Runs a health check (allow 5–10 minutes for DB initialization)

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:8122/openmrs` |
| **Username** | `admin` |
| **Password** | `Admin123` (change immediately after first login) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8122` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/openmrs/` | All service data and configuration |
| `/root/docker/openmrs/data/` | OpenMRS application data |

---

## Management

```bash
# Follow logs
docker logs -f openmrs

# Stop
cd /root/docker/openmrs && docker compose down

# Start
cd /root/docker/openmrs && docker compose up -d

# Update to latest image
cd /root/docker/openmrs && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8122/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
