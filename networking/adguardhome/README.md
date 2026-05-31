# AdGuard Home — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

AdGuard Home is a network-wide DNS-based ad and tracker blocker that operates as a private DNS server for your entire network.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is AdGuard Home?

AdGuard Home functions as a DNS server that filters advertising and tracking domains before they reach any device on your network. It supports DNS-over-HTTPS and DNS-over-TLS, offers detailed query logs, and provides per-client filtering rules. It is commonly used as a self-hosted alternative to Pi-hole.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/networking/adguardhome/adguardhome-ubuntu.sh
chmod +x adguardhome-ubuntu.sh
sudo bash adguardhome-ubuntu.sh
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
| **Web UI (Setup)** | `http://SERVER_IP:3000` (initial setup wizard) |
| **Admin UI** | `http://SERVER_IP:80` (after setup) |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3000` | TCP | Initial setup wizard |
| `80` | TCP | Admin web UI (after setup) |
| `53` | TCP/UDP | DNS queries |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/adguardhome/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f adguardhome

# Stop
cd /root/docker/adguardhome && docker compose down

# Start
cd /root/docker/adguardhome && docker compose up -d

# Update to latest image
cd /root/docker/adguardhome && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 53/tcp, 53/udp, 80/tcp, and 3000/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
