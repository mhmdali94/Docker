# Excalidraw — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Excalidraw is a virtual collaborative whiteboard with a hand-drawn aesthetic, ideal for diagrams, wireframes, and visual brainstorming.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Excalidraw?

Excalidraw is a popular open-source diagramming tool with an intentional hand-drawn style. It supports real-time collaboration, libraries of shapes, image embedding, and exports to PNG/SVG. It requires no login to use and is widely adopted for quick diagrams, architecture drawings, and wireframes.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/excalidraw/excalidraw-ubuntu.sh
chmod +x excalidraw-ubuntu.sh
sudo bash excalidraw-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Starts the Excalidraw container
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:3002` |
| **Username** | N/A — no login required |
| **Password** | N/A — no login required |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3002` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/excalidraw/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f excalidraw

# Stop
cd /root/docker/excalidraw && docker compose down

# Start
cd /root/docker/excalidraw && docker compose up -d

# Update to latest image
cd /root/docker/excalidraw && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 3002/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
