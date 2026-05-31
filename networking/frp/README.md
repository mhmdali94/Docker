# FRP Server — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

FRP (Fast Reverse Proxy) is a high-performance reverse proxy that exposes local services behind NAT or firewalls to the internet via a public server.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is FRP?

FRP consists of a server component (frps) running on a public server and a client component (frpc) running behind NAT. The client connects outbound to the server, which routes public traffic back through the tunnel to the local service. It supports TCP, UDP, HTTP, and HTTPS forwarding with an optional web dashboard.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/networking/frp/frp-ubuntu.sh
chmod +x frp-ubuntu.sh
sudo bash frp-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates a secure tunnel token and dashboard password
- Starts the FRP server
- Runs a health check

---

## Access

| | |
|---|---|
| **Web Dashboard** | `http://SERVER_IP:7500` |
| **Username** | `admin` |
| **Password** | Auto-generated during install (displayed in terminal) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `7000` | TCP | Client (frpc) connection port |
| `7500` | TCP | Web dashboard |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/frp/` | All service data and configuration |
| `/root/docker/frp/frps.toml` | Server configuration including the tunnel token |

---

## Connecting a Client

Install frpc on the machine behind NAT and configure it with:

```toml
serverAddr = "YOUR_SERVER_IP"
serverPort = 7000
auth.method = "token"
auth.token = "YOUR_TUNNEL_TOKEN"
```

The tunnel token is printed in the terminal at install time and stored in `/root/docker/frp/frps.toml`.

---

## Management

```bash
# Follow logs
docker logs -f frps

# Stop
cd /root/docker/frp && docker compose down

# Start
cd /root/docker/frp && docker compose up -d

# Update to latest image
cd /root/docker/frp && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 7000/tcp and 7500/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
