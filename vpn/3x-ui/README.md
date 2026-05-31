# 3X-UI — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

3X-UI is a powerful web-based panel for managing V2Ray and Xray proxy protocols with a modern, user-friendly interface.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is 3X-UI?

3X-UI is a web management panel for Xray-core that simplifies the creation and management of proxy servers. It supports multiple protocols including VMess, VLESS, Trojan, Shadowsocks, and more. The panel provides a clean interface for managing inbound/outbound connections, user accounts, traffic statistics, and certificate management. It is a popular choice for self-hosted proxy infrastructure.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/vpn/3x-ui/3x-ui-ubuntu.sh
chmod +x 3x-ui-ubuntu.sh
sudo bash 3x-ui-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:2053` |
| **Setup** | Configure on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `2053` | TCP | Web Panel |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/3x-ui/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f 3x-ui

# Stop
cd /root/docker/3x-ui && docker compose down

# Start
cd /root/docker/3x-ui && docker compose up -d

# Update to latest image
cd /root/docker/3x-ui && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 2053/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
