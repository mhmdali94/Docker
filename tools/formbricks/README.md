# Formbricks — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Formbricks is an open-source survey and form builder for creating in-app surveys, NPS forms, customer feedback widgets, and product research forms.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Formbricks?

Formbricks is a self-hosted alternative to Typeform and SurveyMonkey. It allows you to build targeted in-product surveys, link surveys, and feedback widgets. Features include conditional logic, multi-language support, webhooks, integrations (Slack, Notion, Zapier), and detailed analytics on responses.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/formbricks/formbricks-ubuntu.sh
chmod +x formbricks-ubuntu.sh
sudo bash formbricks-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for your server IP or domain
- Generates secure credentials
- Starts Formbricks and PostgreSQL
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:3001` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3001` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/formbricks/` | All service data and configuration |
| `/root/docker/formbricks/uploads/` | Uploaded media |
| `/root/docker/formbricks/postgres/` | Database storage |

---

## Management

```bash
# Follow logs
docker logs -f formbricks

# Stop
cd /root/docker/formbricks && docker compose down

# Start
cd /root/docker/formbricks && docker compose up -d

# Update to latest image
cd /root/docker/formbricks && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 3001/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
