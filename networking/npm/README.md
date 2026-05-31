# Nginx Proxy Manager — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Nginx Proxy Manager provides a web UI for managing Nginx reverse proxy hosts, SSL certificates, and access control lists without editing config files.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Nginx Proxy Manager?

Nginx Proxy Manager (NPM) is a Docker-based application that wraps Nginx with a clean web interface. It makes it easy to set up reverse proxy rules, obtain free Let's Encrypt TLS certificates, configure basic auth, and manage access lists — all through a browser. It is widely used to front self-hosted services.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/networking/npm/npm-ubuntu.sh
chmod +x npm-ubuntu.sh
sudo bash npm-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure database credentials
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Admin Web UI** | `http://SERVER_IP:81` |
| **Email** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address. On first visit you will be prompted to create your admin account.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `80` | TCP | HTTP proxy traffic |
| `81` | TCP | Admin web UI |
| `443` | TCP | HTTPS proxy traffic |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/npm/` | All service data and configuration |
| `/root/docker/npm/data/` | Proxy host configs and certificates |
| `/root/docker/npm/letsencrypt/` | Let's Encrypt certificate storage |

---

## Management

```bash
# Follow logs
docker logs -f npm_app

# Stop
cd /root/docker/npm && docker compose down

# Start
cd /root/docker/npm && docker compose up -d

# Update to latest image
cd /root/docker/npm && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 80/tcp, 81/tcp, and 443/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
