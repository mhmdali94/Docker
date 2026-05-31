# Cloudflared — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Cloudflared runs a Cloudflare Tunnel agent that securely exposes local services to the internet without opening any inbound firewall ports.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Cloudflared?

Cloudflare Tunnel creates an outbound-only encrypted connection from your server to Cloudflare's global network. This allows you to expose internal services publicly without a public IP or open firewall ports. You manage hostnames and routing rules from the Cloudflare Zero Trust dashboard.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/networking/cloudflared/cloudflared-ubuntu.sh
chmod +x cloudflared-ubuntu.sh
sudo bash cloudflared-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for your Cloudflare Tunnel token
- Starts the tunnel container
- Verifies tunnel registration

---

## Pre-requisite

You need a Cloudflare account and a tunnel token:

1. Log in to [https://one.dash.cloudflare.com](https://one.dash.cloudflare.com)
2. Go to **Networks → Tunnels → Create a Tunnel**
3. Copy the tunnel token shown in the setup step

---

## Access

| | |
|---|---|
| **Management Dashboard** | [https://one.dash.cloudflare.com](https://one.dash.cloudflare.com) |

> Cloudflared uses outbound connections only — no inbound ports are required on your server.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| None | — | Outbound only — no listening ports required |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/cloudflared/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f cloudflared

# Stop
cd /root/docker/cloudflared && docker compose down

# Start
cd /root/docker/cloudflared && docker compose up -d

# Update to latest image
cd /root/docker/cloudflared && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- A Cloudflare account with a configured tunnel token

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
