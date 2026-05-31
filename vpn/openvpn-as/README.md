# OpenVPN Access Server — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

OpenVPN Access Server is a full-featured VPN solution with a web-based admin UI for managing users, connections, and configurations.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is OpenVPN Access Server?

OpenVPN Access Server provides an enterprise-ready VPN solution with a polished web interface for administration and client management. It supports OpenVPN protocol with TLS encryption, offers per-user and per-group access policies, and includes a client web portal where users can download pre-configured VPN clients. It handles certificate management, two-factor authentication, and traffic routing automatically.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/vpn/openvpn-as/openvpn-as-ubuntu.sh
chmod +x openvpn-as-ubuntu.sh
sudo bash openvpn-as-ubuntu.sh
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
| **Admin UI** | `https://SERVER_IP:943/admin` |
| **Client Portal** | `https://SERVER_IP:943` |
| **Setup** | Configure on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `943` | TCP | Admin & Client Web UI |
| `1194` | UDP | VPN tunnel |
| `443` | TCP | VPN tunnel (TCP fallback) |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/openvpn-as/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f openvpn-as

# Stop
cd /root/docker/openvpn-as && docker compose down

# Start
cd /root/docker/openvpn-as && docker compose up -d

# Update to latest image
cd /root/docker/openvpn-as && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 943, 443/tcp and 1194/udp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
