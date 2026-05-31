# Seafile — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Seafile is a high-performance, enterprise-grade file sync and share platform that lets you host your own cloud storage with client-side encryption support.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Seafile?

Seafile provides file synchronization across devices, file sharing with access controls, and optional client-side encryption for maximum privacy. It is known for its reliability and speed even with large libraries, making it suitable for teams and power users who demand more than basic cloud storage.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/files/seafile/seafile-ubuntu.sh
chmod +x seafile-ubuntu.sh
sudo bash seafile-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:8090` |
| **Username** | `admin@seafile.local` |
| **Password** | Auto-generated during install (displayed in terminal) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8090` | TCP | Web UI / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/seafile/` | All service data and configuration |
| `/root/docker/seafile/data/` | File storage and MariaDB database |

---

## Management

```bash
# Follow logs
docker logs -f seafile

# Stop
cd /root/docker/seafile && docker compose down

# Start
cd /root/docker/seafile && docker compose up -d

# Update to latest image
cd /root/docker/seafile && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8090/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
