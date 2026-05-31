# Outline VPN Server — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Outline VPN is a simple self-hosted Shadowsocks VPN by Google Jigsaw, managed via the Outline Manager desktop app.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Outline VPN?

Outline VPN makes it easy to run your own VPN server. It uses the Shadowsocks protocol for encrypted traffic and provides the Outline Manager desktop application for server administration and key management. Clients connect using the Outline app (available for all major platforms) by scanning an access key or clicking a share link. It is designed to be simple, resistant to blocking, and easy to maintain.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/vpn/outline/outline-ubuntu.sh
chmod +x outline-ubuntu.sh
sudo bash outline-ubuntu.sh
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
| **Management** | Via Outline Manager desktop app |
| **Clients** | Connect via Outline client app |

> Use the Outline Manager app to add this server using the connection details shown after install.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `443` | TCP | Shadowsocks + Management API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/outline/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f outline

# Stop
cd /root/docker/outline && docker compose down

# Start
cd /root/docker/outline && docker compose up -d

# Update to latest image
cd /root/docker/outline && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 443/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
