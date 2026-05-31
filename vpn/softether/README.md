# SoftEther VPN Server — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

SoftEther VPN is a multi-protocol VPN server supporting L2TP/IPsec, SSTP, OpenVPN, and SoftEther protocol in one container.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is SoftEther VPN?

SoftEther VPN is an open-source, multi-protocol VPN server developed as an academic project at the University of Tsukuba. It supports multiple VPN protocols simultaneously — L2TP/IPsec (for native mobile/Windows clients), SSTP (for Windows), OpenVPN, and the proprietary SoftEther protocol. This makes it compatible with virtually any device without installing additional software. The management interface is accessible via a web panel on port 5555.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/vpn/softether/softether-ubuntu.sh
chmod +x softether-ubuntu.sh
sudo bash softether-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for VPN credentials (PSK, username, password)
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Management** | `http://SERVER_IP:5555` |
| **L2TP/IPsec** | Connect with PSK + VPN credentials |
| **Management Password** | Set during install |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `500` | UDP | L2TP IKE |
| `4500` | UDP | L2TP NAT-T |
| `1701` | TCP | L2TP |
| `1194` | UDP | OpenVPN |
| `443` | TCP | SSTP / SoftEther |
| `5555` | TCP | Management UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/softether/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f softether-vpn

# Stop
cd /root/docker/softether && docker compose down

# Start
cd /root/docker/softether && docker compose up -d

# Update to latest image
cd /root/docker/softether && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 500, 4500, 1194/udp and 443, 1701, 5555/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
