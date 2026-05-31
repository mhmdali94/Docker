# Rocket.Chat — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Self-hosted team messaging and collaboration platform — a Slack alternative with channels, DMs, video calls, and integrations.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Rocket.Chat?

Rocket.Chat is a comprehensive open-source communication platform with channels, direct messages, threads, file sharing, video conferencing, and a marketplace of integrations. It supports LDAP, SAML, and OAuth for enterprise authentication, has iOS and Android apps, and offers a LiveChat module for customer support — a self-hosted alternative to Slack.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/communication/rocketchat/rocketchat-ubuntu.sh
chmod +x rocketchat-ubuntu.sh
sudo bash rocketchat-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:3100` |
| **Username** | First user to register becomes admin |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3100` | TCP | Web UI / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/rocketchat/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f rocketchat

# Stop the service
cd /root/docker/rocketchat && docker compose down

# Start the service
cd /root/docker/rocketchat && docker compose up -d

# Update to latest image
cd /root/docker/rocketchat && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Minimum 2 GB RAM
- Ports open in firewall: 3100/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
