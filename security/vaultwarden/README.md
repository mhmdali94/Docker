# Vaultwarden — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Vaultwarden is a lightweight self-hosted Bitwarden-compatible password manager server that works with all official Bitwarden clients and browser extensions.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Vaultwarden?

Vaultwarden is an unofficial, community-developed Bitwarden server implementation written in Rust. It is API-compatible with the official Bitwarden clients and browser extensions, allowing you to self-host your entire password management infrastructure at a fraction of the resource cost of the official server. It supports organizations, collections, Authenticator TOTP, and the full Bitwarden feature set.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/security/vaultwarden/vaultwarden-ubuntu.sh
chmod +x vaultwarden-ubuntu.sh
sudo bash vaultwarden-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:8071` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8071` | TCP | Web UI / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/vaultwarden/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f vaultwarden

# Stop
cd /root/docker/vaultwarden && docker compose down

# Start
cd /root/docker/vaultwarden && docker compose up -d

# Update to latest image
cd /root/docker/vaultwarden && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8071/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
