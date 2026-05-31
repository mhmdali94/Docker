# Open Source POS — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Open Source POS is a web-based point-of-sale system for retail shops, providing product management, customer tracking, sales, inventory, and report generation from a browser.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Open Source POS?

Open Source POS is a CodeIgniter 4 application that provides a full-featured retail POS system. It supports multiple locations, barcode scanning, supplier management, inventory tracking, customer accounts, and detailed sales reporting. It is accessible entirely through a web browser with no desktop software required.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/pos/opensourcepos/opensourcepos-ubuntu.sh
chmod +x opensourcepos-ubuntu.sh
sudo bash opensourcepos-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Builds the application from source (takes 3–5 minutes)
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:8888` |
| **Username** | `admin` |
| **Password** | `pointofsale` |

> Replace `SERVER_IP` with your server's actual IP address.
> **Change the default password immediately after first login.**

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8888` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/opensourcepos/` | All service data and configuration |
| `/root/docker/opensourcepos/mysql/` | Database storage |

---

## Management

```bash
# Follow logs
docker logs -f opensourcepos

# Stop
cd /root/docker/opensourcepos && docker compose down

# Start
cd /root/docker/opensourcepos && docker compose up -d

# Update to latest image
cd /root/docker/opensourcepos && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8888/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
