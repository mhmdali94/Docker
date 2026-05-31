# IT-Tools — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

IT-Tools is a collection of 100+ handy online utilities for developers and IT professionals, all accessible from a clean self-hosted web interface.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is IT-Tools?

IT-Tools provides a comprehensive set of browser-based utilities including base64 encoder/decoder, UUID generator, JWT decoder, hash generators, color converters, regex testers, URL parsers, YAML/JSON converters, QR code generators, and many more. It requires no login and runs entirely in the browser — no data is sent to any external server.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/it-tools/it-tools-ubuntu.sh
chmod +x it-tools-ubuntu.sh
sudo bash it-tools-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Starts the IT-Tools container
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:8080` |
| **Username** | N/A — no login required |
| **Password** | N/A — no login required |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8080` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/it-tools/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f it-tools

# Stop
cd /root/docker/it-tools && docker compose down

# Start
cd /root/docker/it-tools && docker compose up -d

# Update to latest image
cd /root/docker/it-tools && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8080/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
