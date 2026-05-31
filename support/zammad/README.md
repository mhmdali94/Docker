# Zammad — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Zammad is a full-featured open-source helpdesk and ticketing system for managing support requests from email, chat, phone, and social media in one place.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Zammad?

Zammad is a modern, enterprise-grade customer support platform. It centralizes tickets from multiple channels (email, web form, chat, Twitter, Facebook), provides a powerful search powered by Elasticsearch, supports SLAs, workflows, automation, and integrates with LDAP and OAuth providers. It is a self-hosted alternative to Zendesk or Freshdesk.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/support/zammad/zammad-ubuntu.sh
chmod +x zammad-ubuntu.sh
sudo bash zammad-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Starts the full Zammad stack (Rails, Websocket, Nginx, PostgreSQL, Redis, Elasticsearch, Memcached)
- Runs a health check (first start takes 2–4 minutes)

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:3036` |
| **Username** | Created on first visit (setup wizard) |
| **Password** | Created on first visit (setup wizard) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3036` | TCP | Web UI (Nginx) |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/zammad/` | All service data and configuration |
| `/root/docker/zammad/storage/` | Attachments and uploads |
| `/root/docker/zammad/postgres/` | Database storage |
| `/root/docker/zammad/elasticsearch/` | Search index |

---

## Management

```bash
# Follow logs
docker logs -f zammad-railsserver
docker logs -f zammad-nginx

# Stop
cd /root/docker/zammad && docker compose down

# Start
cd /root/docker/zammad && docker compose up -d

# Update to latest image
cd /root/docker/zammad && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 3036/tcp open in firewall
- At least 4 GB RAM recommended

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
