# Typebot — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Typebot is a visual chatbot and form builder — create conversational flows and embed them on any website without writing code.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Typebot?

Typebot provides a drag-and-drop visual builder for creating chatbots, lead generation forms, surveys, and conversational experiences. Bots can be embedded on websites, shared via links, or integrated with messaging platforms. It supports conditional logic, variables, file uploads, payment collection (Stripe), email notifications, and webhook integrations. The builder (design interface) and viewer (runtime) run as separate containers behind a PostgreSQL database.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/typebot/typebot-ubuntu.sh
chmod +x typebot-ubuntu.sh
sudo bash typebot-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure database password and secrets
- Starts Typebot Builder, Viewer, and PostgreSQL 15
- Runs a health check

---

## Access

| | |
|---|---|
| **Builder** | `http://SERVER_IP:3310` |
| **Viewer** | `http://SERVER_IP:3311` |
| **Email** | `admin@typebot.local` |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3310` | TCP | Builder (admin interface) |
| `3311` | TCP | Viewer (public bot runtime) |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/typebot/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f typebot-builder

# Stop
cd /root/docker/typebot && docker compose down

# Start
cd /root/docker/typebot && docker compose up -d

# Update to latest image
cd /root/docker/typebot && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 3310, 3311/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
