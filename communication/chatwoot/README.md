# Chatwoot — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Open-source customer support and live chat platform — manage conversations from email, live chat, social media, and APIs in one unified inbox.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Chatwoot?

Chatwoot is an open-source customer engagement platform that aggregates conversations from email, live chat widgets, WhatsApp, Twitter, Facebook, and API channels into a single team inbox. It features canned responses, conversation labels, team assignment, reports, and a customer contact book — a self-hosted alternative to Intercom and Zendesk.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/communication/chatwoot/chatwoot-ubuntu.sh
chmod +x chatwoot-ubuntu.sh
sudo bash chatwoot-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:3008` |
| **Sign up** | `http://SERVER_IP:3008/auth/sign_up` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3008` | TCP | Web UI / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/chatwoot/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f chatwoot-server

# Stop the service
cd /root/docker/chatwoot && docker compose down

# Start the service
cd /root/docker/chatwoot && docker compose up -d

# Update to latest image
cd /root/docker/chatwoot && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 3008/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
