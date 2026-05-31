# Payload CMS — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

TypeScript-first headless CMS built for developers — define your schema in code and get a full admin UI and REST/GraphQL API instantly.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Payload CMS?

Payload CMS is a developer-first open-source headless CMS where the schema is defined in TypeScript rather than a GUI. It automatically generates a full-featured admin panel, REST API, and GraphQL API from your schema. Supports access control, hooks, versioning, localization, and works as a backend for Next.js, Nuxt, SvelteKit, and other frameworks.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/cms/payload/payload-ubuntu.sh
chmod +x payload-ubuntu.sh
sudo bash payload-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates a secure payload secret
- Starts the service stack (Payload CMS + MongoDB)
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI / Admin** | `http://SERVER_IP:3030/admin` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3030` | TCP | Web UI / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/payload/` | All service data and configuration |
| `/root/docker/payload/media/` | Uploaded media files |
| `/root/docker/payload/mongo/` | MongoDB database files |

---

## Management

```bash
# Follow logs
docker logs -f payload

# Stop
cd /root/docker/payload && docker compose down

# Start
cd /root/docker/payload && docker compose up -d

# Update to latest image
cd /root/docker/payload && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 3030/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
