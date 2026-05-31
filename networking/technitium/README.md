# Technitium DNS Server — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Technitium DNS Server is a feature-rich self-hosted DNS server with a web UI, ad blocking, DNS-over-HTTPS, and split-horizon support.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Technitium DNS Server?

Technitium is a full-featured authoritative and recursive DNS server. It supports DNS-over-HTTPS (DoH), DNS-over-TLS (DoT), DNSSEC, ad blocking via block lists, custom DNS zones, split-horizon, and extensive query logging — all manageable through a clean web dashboard.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/networking/technitium/technitium-ubuntu.sh
chmod +x technitium-ubuntu.sh
sudo bash technitium-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Disables `systemd-resolved` to free port 53
- Generates a secure admin password
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:5380` |
| **Username** | `admin` |
| **Password** | Auto-generated during install (displayed in terminal) |

> Replace `SERVER_IP` with your server's actual IP address.

> **Note:** The script automatically disables `systemd-resolved` to free port 53, and sets `8.8.8.8` as a temporary resolver during setup.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `53` | TCP | DNS queries |
| `53` | UDP | DNS queries |
| `5380` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/technitium/` | All service data and configuration |
| `/root/docker/technitium/data/` | DNS zones, configuration, and logs |

---

## Management

```bash
# Follow logs
docker logs -f technitium-dns

# Stop
cd /root/docker/technitium && docker compose down

# Start
cd /root/docker/technitium && docker compose up -d

# Update to latest image
cd /root/docker/technitium && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 53/tcp, 53/udp, and 5380/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
