# Zulip — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Powerful open-source team chat with unique topic-based threading that keeps conversations organized in large, fast-moving teams.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Zulip?

Zulip is an open-source team messaging platform with a distinctive topic-based threading model that organizes every conversation. Unlike flat-channel chat, Zulip's streams and topics make it possible to follow dozens of conversations without noise. It includes powerful search, keyboard navigation, integrations, and iOS/Android apps — a self-hosted Slack alternative.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/communication/zulip/zulip-ubuntu.sh
chmod +x zulip-ubuntu.sh
sudo bash zulip-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:8585` |
| **Email** | Auto-generated (shown at install) |
| **Password** | Auto-generated (shown at install) |

> Replace `SERVER_IP` with your server's IP address. First startup takes 3-5 minutes for database initialization.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8585` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/zulip/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f zulip

# Stop the service
cd /root/docker/zulip && docker compose down

# Start the service
cd /root/docker/zulip && docker compose up -d

# Update to latest image
cd /root/docker/zulip && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 8585/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
