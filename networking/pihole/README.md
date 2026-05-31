# Pi-hole — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Pi-hole is a network-wide ad blocker that acts as a DNS sinkhole, blocking advertising and tracking domains for every device on your network.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Pi-hole?

Pi-hole works as a local DNS server that intercepts domain name lookups. When a device requests a known ad or tracker domain, Pi-hole returns a blank response, effectively blocking the request network-wide without touching any device. It provides a web dashboard with query logs, block lists, and per-client statistics.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/networking/pihole/pihole-ubuntu.sh
chmod +x pihole-ubuntu.sh
sudo bash pihole-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP/admin` |
| **Password** | Auto-generated during install (displayed in terminal) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `53` | TCP/UDP | DNS queries |
| `80` | TCP | Admin web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/pihole/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f pihole

# Stop
cd /root/docker/pihole && docker compose down

# Start
cd /root/docker/pihole && docker compose up -d

# Update to latest image
cd /root/docker/pihole && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 53/tcp, 53/udp, and 80/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
