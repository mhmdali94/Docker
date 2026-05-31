# Node-RED — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Flow-based visual programming for event-driven automation — ideal for IoT, home automation, and API wiring.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Node-RED?

Node-RED is a flow-based programming tool for wiring together hardware devices, APIs, and online services with a browser-based visual editor. Drag and connect nodes from the palette to build event-driven workflows without writing much code. Widely used for IoT automation, home automation (Home Assistant integration), HTTP API bridging, and data transformation.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/automation/node-red/node-red-ubuntu.sh
chmod +x node-red-ubuntu.sh
sudo bash node-red-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates a secure credential secret
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:1880` |
| **Username** | None (open access in demo mode) |
| **Password** | None (open access in demo mode) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `1880` | TCP | Flow Editor / HTTP endpoints |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/node-red/` | All service data and configuration |
| `/root/docker/node-red/data/` | Flows, credentials, and settings |

---

## Management

```bash
# Follow logs
docker logs -f node-red

# Stop
cd /root/docker/node-red && docker compose down

# Start
cd /root/docker/node-red && docker compose up -d

# Update to latest image
cd /root/docker/node-red && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 1880/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
