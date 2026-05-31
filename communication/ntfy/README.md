# ntfy — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Simple HTTP-based pub/sub push notification service — send notifications to your phone or desktop with a plain HTTP request.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is ntfy?

ntfy is a simple, open-source push notification service that works over plain HTTP. Publish a message with a single `curl` command to a topic, and any subscriber (phone app, browser, script) receives it instantly. No accounts required for basic use. The iOS and Android apps support multiple servers and topics with rich notification customization.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/communication/ntfy/ntfy-ubuntu.sh
chmod +x ntfy-ubuntu.sh
sudo bash ntfy-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:8095` |
| **Authentication** | Open read-write by default |

> Replace `SERVER_IP` with your server's IP address. Publish: `curl -d "Hello!" http://SERVER_IP:8095/my-topic`

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8095` | TCP | Web UI / HTTP API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/ntfy/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f ntfy

# Stop the service
cd /root/docker/ntfy && docker compose down

# Start the service
cd /root/docker/ntfy && docker compose up -d

# Update to latest image
cd /root/docker/ntfy && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 8095/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
