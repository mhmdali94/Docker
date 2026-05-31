# Remotely — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Remotely is a self-hosted remote desktop and remote support platform that allows technicians to access and control remote machines through a browser.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Remotely?

Remotely is an open-source remote support tool similar to TeamViewer or AnyDesk. It provides browser-based remote desktop access, unattended access, scripting, and a multi-tenant dashboard for managing remote machines. Agents are installed on target machines and connect back to the self-hosted server.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/remote-access/remotely/remotely-ubuntu.sh
chmod +x remotely-ubuntu.sh
sudo bash remotely-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:5000` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `5000` | TCP | Web UI / Agent connections |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/remotely/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f remotely

# Stop
cd /root/docker/remotely && docker compose down

# Start
cd /root/docker/remotely && docker compose up -d

# Update to latest image
cd /root/docker/remotely && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 5000/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
