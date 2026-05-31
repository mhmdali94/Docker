# Pritunl — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Pritunl is an enterprise-grade self-hosted VPN server supporting OpenVPN and WireGuard with a polished web management UI.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Pritunl?

Pritunl is a distributed VPN server that supports both OpenVPN and WireGuard protocols. It provides a clean web interface for managing organizations, users, servers, and routes. Features include two-factor authentication, SSO integration, split tunneling, multi-server clustering, and per-user bandwidth limits. It is designed for both small teams and enterprise deployments.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/vpn/pritunl/pritunl-ubuntu.sh
chmod +x pritunl-ubuntu.sh
sudo bash pritunl-ubuntu.sh
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
| **Web UI** | `https://SERVER_IP:443` |
| **Setup** | Initial setup on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `443` | TCP | Web UI |
| `1194` | UDP | OpenVPN tunnel |
| `51820` | UDP | WireGuard tunnel |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/pritunl/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f pritunl

# Stop
cd /root/docker/pritunl && docker compose down

# Start
cd /root/docker/pritunl && docker compose up -d

# Update to latest image
cd /root/docker/pritunl && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 443/tcp and 1194, 51820/udp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
