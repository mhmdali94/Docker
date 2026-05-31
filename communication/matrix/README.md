# Matrix Synapse + Element Web — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Self-hosted federated, end-to-end encrypted messaging using the Matrix protocol with Element Web client.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Matrix Synapse + Element Web?

Matrix is an open, federated protocol for secure real-time communication. Synapse is the reference Matrix homeserver implementation that handles user accounts, rooms, and federation. Element Web is the full-featured browser client for Matrix — a self-hosted alternative to WhatsApp, Telegram, and Slack with end-to-end encryption.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/communication/matrix/matrix-ubuntu.sh
chmod +x matrix-ubuntu.sh
sudo bash matrix-ubuntu.sh
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
| **Element Web (chat client)** | `http://SERVER_IP:8009` |
| **Synapse API** | `http://SERVER_IP:8008` |
| **Username** | Register via Element Web on first visit |
| **Password** | Register via Element Web on first visit |

> Replace `SERVER_IP` with your server's IP address. Set Homeserver URL to `http://SERVER_IP:8008` when registering.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8008` | TCP | Synapse Matrix server API |
| `8009` | TCP | Element Web client |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/matrix/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f synapse

# Stop the service
cd /root/docker/matrix && docker compose down

# Start the service
cd /root/docker/matrix && docker compose up -d

# Update to latest image
cd /root/docker/matrix && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 8008/tcp, 8009/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
