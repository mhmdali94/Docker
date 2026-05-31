# WireGuard Easy — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

WireGuard Easy (wg-easy) is the easiest way to run WireGuard VPN — a Docker container with a simple web UI to create, manage, and download client configurations.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is WireGuard Easy?

WireGuard Easy wraps WireGuard in a Docker container and provides a clean web interface for managing VPN clients. With one click you can create new clients, generate QR codes for mobile devices, download `.conf` files for desktop clients, view traffic statistics, and enable or disable clients. It auto-detects your WAN IP and handles all the complex WireGuard configuration automatically.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/vpn/wireguard-easy/wireguard-easy-ubuntu.sh
chmod +x wireguard-easy-ubuntu.sh
sudo bash wireguard-easy-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:51821` |
| **Password** | Auto-generated during install (shown in terminal) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `51821` | TCP | Web UI |
| `51820` | UDP | WireGuard VPN tunnel |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/wireguard-easy/` | All service data and configuration |
| `/root/docker/wireguard-easy/data/` | WireGuard config & client keys |

---

## Management

```bash
# Follow logs
docker logs -f wireguard-easy

# Stop
cd /root/docker/wireguard-easy && docker compose down

# Start
cd /root/docker/wireguard-easy && docker compose up -d

# Update to latest image
cd /root/docker/wireguard-easy && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 51821/tcp and 51820/udp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
