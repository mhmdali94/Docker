# Netbird — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Netbird is a WireGuard-based mesh VPN with a self-hosted control plane. Includes a bundled Dex OIDC identity provider so login works out of the box.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Netbird?

Netbird creates a secure overlay network connecting your devices anywhere in the world using WireGuard for encryption. Unlike traditional VPNs, it uses a peer-to-peer mesh architecture — devices connect directly when possible, falling back to relay servers when needed. This installer includes a complete self-hosted stack with a management service, signal service, dashboard, Dex OIDC for authentication, Coturn for NAT traversal, and Caddy as a reverse proxy with automatic TLS.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/vpn/netbird/netbird-ubuntu.sh
chmod +x netbird-ubuntu.sh
sudo bash netbird-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates domain via nip.io
- Configures OIDC, TURN, and Caddy
- Starts 6 services (Caddy, Signal, Management, Dashboard, Dex, Coturn)
- Runs a health check

---

## Access

| | |
|---|---|
| **Dashboard** | `https://[auto-generated-domain]` |
| **Email** | `admin@netbird.local` |
| **Password** | `changeme2024` (change immediately) |

> The domain is auto-generated using nip.io and displayed in the terminal.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `80` | TCP | HTTP (redirects to HTTPS) |
| `443` | TCP | HTTPS Dashboard |
| `10000` | TCP | Signal gRPC |
| `3478` | UDP | TURN (NAT traversal) |
| `49152–65535` | UDP | TURN media relay |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/netbird/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f netbird-management

# Stop
cd /root/docker/netbird && docker compose down

# Start
cd /root/docker/netbird && docker compose up -d

# Update to latest image
cd /root/docker/netbird && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 80, 443, 10000/tcp and 3478, 49152–65535/udp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
