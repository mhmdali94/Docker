# Verdaccio — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Lightweight private npm registry — proxy, cache, and publish packages locally.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Verdaccio?

Verdaccio is a simple, open-source private npm registry. It can proxy npmjs.org and cache packages locally for offline access, host private packages that never leave your network, and serve as a drop-in replacement for the npm registry. Lightweight enough to run on any server with minimal resources.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/verdaccio/verdaccio-ubuntu.sh
chmod +x verdaccio-ubuntu.sh
sudo bash verdaccio-ubuntu.sh
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
| **Web UI / Registry** | `http://SERVER_IP:4873` |
| **Authentication** | None in demo mode |

> Replace `SERVER_IP` with your server's IP address. Set npm registry: `npm set registry http://SERVER_IP:4873`

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `4873` | TCP | Web UI / npm Registry |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/verdaccio/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f verdaccio

# Stop the service
cd /root/docker/verdaccio && docker compose down

# Start the service
cd /root/docker/verdaccio && docker compose up -d

# Update to latest image
cd /root/docker/verdaccio && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 4873/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
