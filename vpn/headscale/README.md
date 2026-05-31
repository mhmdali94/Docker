# Headscale — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Headscale is a self-hosted, open-source implementation of the Tailscale control server — use all Tailscale clients with your own server.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Headscale?

Headscale is an independent implementation of the Tailscale coordination server, allowing you to self-host your own mesh VPN control plane. It is fully compatible with all official Tailscale clients (Windows, macOS, Linux, iOS, Android), so devices connect exactly as they would with Tailscale's hosted service — but all metadata and coordination happen on your own infrastructure. It uses WireGuard under the hood for encrypted peer-to-peer connections.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/vpn/headscale/headscale-ubuntu.sh
chmod +x headscale-ubuntu.sh
sudo bash headscale-ubuntu.sh
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
| **API** | `http://SERVER_IP:8080` |
| **Username** | Managed via CLI |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8080` | TCP | Headscale API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/headscale/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f headscale

# Stop
cd /root/docker/headscale && docker compose down

# Start
cd /root/docker/headscale && docker compose up -d

# Update to latest image
cd /root/docker/headscale && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8080/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
