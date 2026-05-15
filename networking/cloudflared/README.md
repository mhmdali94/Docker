# Cloudflared (Cloudflare Tunnel)

Expose self-hosted services to the internet without opening firewall ports — tunnels traffic through Cloudflare's network.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/networking/cloudflared/cloudflared-ubuntu.sh
chmod +x cloudflared-ubuntu.sh
sudo bash cloudflared-ubuntu.sh
```

## What It Installs

- **Cloudflared** — Cloudflare Tunnel connector daemon

## Credentials

| Field | Value |
| --- | --- |
| Tunnel Token | Required — obtained from Cloudflare Zero Trust dashboard |

## Ports

| Port | Service |
| --- | --- |
| — | Outbound tunnel only, no inbound ports |

## Connect

1. Log in to [Cloudflare Zero Trust](https://one.dash.cloudflare.com) → Networks → Tunnels
2. Create a tunnel, copy the token
3. Run this installer and paste the token when prompted
4. Add public hostnames in the Cloudflare dashboard to route traffic to your local services
