# Strapi — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Open-source headless CMS — build your content structure visually and consume it via REST or GraphQL API with any frontend framework.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Strapi?

Strapi is the leading open-source headless CMS that lets you design content types through a visual builder and immediately exposes them via REST and GraphQL APIs. It supports role-based access control, webhooks, media management, internationalization, and plugins. Compatible with any frontend framework — React, Vue, Next.js, Nuxt, and more.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/cms/strapi/strapi-ubuntu.sh
chmod +x strapi-ubuntu.sh
sudo bash strapi-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure app keys, API token salt, JWT secrets, and transfer token salt
- Starts the service stack (Strapi + PostgreSQL)
- Runs a health check

---

## Access

| | |
|---|---|
| **Admin Panel** | `http://SERVER_IP:1337/admin` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `1337` | TCP | Admin UI / REST API / GraphQL |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/strapi/` | All service data and configuration |
| `/root/docker/strapi/uploads/` | Uploaded media files |
| `/root/docker/strapi/postgres/` | PostgreSQL database files |

---

## Management

```bash
# Follow logs
docker logs -f strapi

# Stop
cd /root/docker/strapi && docker compose down

# Start
cd /root/docker/strapi && docker compose up -d

# Update to latest image
cd /root/docker/strapi && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 1337/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
