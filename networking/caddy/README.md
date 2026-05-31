# Caddy — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Caddy is a modern, automatic HTTPS web server and reverse proxy that provisions TLS certificates automatically via Let's Encrypt.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Caddy?

Caddy is a powerful, production-ready open-source web server written in Go. It automatically obtains and renews TLS certificates from Let's Encrypt, supports HTTP/2 and HTTP/3, and provides simple declarative configuration via Caddyfile. It is widely used as a reverse proxy to front other self-hosted services with zero-config TLS.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/networking/caddy/caddy-ubuntu.sh
chmod +x caddy-ubuntu.sh
sudo bash caddy-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Writes a default Caddyfile
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Web (HTTP)** | `http://SERVER_IP:80` |
| **Admin API** | `http://SERVER_IP:2019` |
| **Username** | N/A — no login required |
| **Password** | N/A — no login required |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `80` | TCP | HTTP |
| `443` | TCP | HTTPS (auto TLS) |
| `2019` | TCP | Admin API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/caddy/` | All service data and configuration |
| `/root/docker/caddy/config/Caddyfile` | Main configuration file (auto-reloads on change) |
| `/root/docker/caddy/data/` | TLS certificates and state |
| `/root/docker/caddy/site/` | Static file root |

---

## Configuration

Edit `/root/docker/caddy/config/Caddyfile` to add reverse proxy rules. Example:

```
yourdomain.com {
    reverse_proxy localhost:8080
}
```

Point a domain at this server's IP and Caddy will obtain a TLS certificate automatically.

---

## Management

```bash
# Follow logs
docker logs -f caddy

# Stop
cd /root/docker/caddy && docker compose down

# Start
cd /root/docker/caddy && docker compose up -d

# Update to latest image
cd /root/docker/caddy && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 80/tcp and 443/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
