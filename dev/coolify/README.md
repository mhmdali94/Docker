# Coolify — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Self-hosted Heroku/Netlify alternative — deploy apps, databases, and services from Git with one click on your own server.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Coolify?

Coolify is an open-source self-hosting platform that lets you deploy applications, databases, and services directly from Git repositories with a Heroku-like experience. It supports Node.js, PHP, Python, Go, static sites, Docker Compose, and 50+ one-click services including WordPress, Ghost, and Plausible. Automatic SSL via Let's Encrypt and multi-server management are included.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/coolify/coolify-ubuntu.sh
chmod +x coolify-ubuntu.sh
sudo bash coolify-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:8000` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8000` | TCP | Dashboard |
| `6001` | TCP | WebSocket |
| `6002` | TCP | Terminal proxy |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/coolify/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f coolify

# Stop the service
cd /root/docker/coolify && docker compose down

# Start the service
cd /root/docker/coolify && docker compose up -d

# Update to latest image
cd /root/docker/coolify && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 8000/tcp, 6001/tcp, 6002/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
