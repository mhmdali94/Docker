# Nexus Repository Manager — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Universal artifact repository — store and serve Maven, npm, Docker images, PyPI, and 20+ other package formats from a single server.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Nexus Repository Manager?

Nexus Repository Manager 3 is a universal artifact repository by Sonatype. It supports proxy, hosted, and group repositories for Maven, npm, Docker, PyPI, NuGet, Helm, Go, and more. Teams use it to cache public packages, host private artifacts, and manage Docker image registries behind a single authenticated endpoint.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/nexus/nexus-ubuntu.sh
chmod +x nexus-ubuntu.sh
sudo bash nexus-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:8081` |
| **Username** | `admin` |
| **Password** | Stored in `/root/docker/nexus/data/admin.password` (shown at install) |

> Replace `SERVER_IP` with your server's IP address. First startup takes ~2 minutes.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8081` | TCP | Web UI / Repository API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/nexus/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f nexus

# Stop the service
cd /root/docker/nexus && docker compose down

# Start the service
cd /root/docker/nexus && docker compose up -d

# Update to latest image
cd /root/docker/nexus && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 8081/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
