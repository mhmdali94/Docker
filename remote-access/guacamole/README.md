# Apache Guacamole — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Apache Guacamole is a clientless remote desktop gateway that supports RDP, VNC, and SSH entirely through a web browser with no plugins required.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Apache Guacamole?

Apache Guacamole acts as a centralized HTML5 remote access gateway. Users connect to remote desktops and servers directly from a browser without installing any client software. It supports RDP (Windows), VNC, SSH, and Telnet, and provides user/group management with connection sharing.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/remote-access/guacamole/guacamole-ubuntu.sh
chmod +x guacamole-ubuntu.sh
sudo bash guacamole-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:8085` |
| **Username** | `guacadmin` |
| **Password** | `guacadmin` |

> Replace `SERVER_IP` with your server's actual IP address.
> **Change the default credentials immediately after first login.**

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8085` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/guacamole/` | All service data and configuration |
| `/root/docker/guacamole/postgres/` | Database storage |

---

## Management

```bash
# Follow logs
docker logs -f guacamole

# Stop
cd /root/docker/guacamole && docker compose down

# Start
cd /root/docker/guacamole && docker compose up -d

# Update to latest image
cd /root/docker/guacamole && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8085/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
