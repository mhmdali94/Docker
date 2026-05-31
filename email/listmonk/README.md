# Listmonk — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

High-performance self-hosted newsletter and mailing list manager with a modern web UI.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Listmonk?

Listmonk is a fast, open-source newsletter and mailing list manager. It provides subscriber management, HTML/plain-text campaign creation, open and click tracking, transactional email support, and a REST API. Listmonk requires an external SMTP provider (Gmail, AWS SES, Postmark, Mailgun) to send emails — it is a management platform, not a mail server.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/email/listmonk/listmonk-ubuntu.sh
chmod +x listmonk-ubuntu.sh
sudo bash listmonk-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:9000` |
| **Username** | `admin` |
| **Password** | Auto-generated (shown at install) |

> Replace `SERVER_IP` with your server's IP address. Configure SMTP under Settings → SMTP after first login.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `9000` | TCP | Web UI / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/listmonk/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f listmonk

# Stop the service
cd /root/docker/listmonk && docker compose down

# Start the service
cd /root/docker/listmonk && docker compose up -d

# Update to latest image
cd /root/docker/listmonk && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 9000/tcp
- External SMTP provider for sending emails

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
