# Lemmy — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Lemmy is a federated link aggregator and forum that is the open-source alternative to Reddit, federating with other Lemmy instances and the wider Fediverse.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Lemmy?

Lemmy is a self-hosted Reddit alternative built on ActivityPub federation. Communities on your instance can subscribe to communities on other Lemmy instances and interact across the Fediverse. It supports communities, posts, comments, voting, moderation, and cross-instance federation. Lemmy requires a real domain name for federation to work.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/social/lemmy/lemmy-ubuntu.sh
chmod +x lemmy-ubuntu.sh
sudo bash lemmy-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for your domain name and admin username
- Generates secure credentials
- Starts the full Lemmy stack (backend, UI, PostgreSQL, pictrs)

---

## Access

| | |
|---|---|
| **Web UI** | `http://YOUR_DOMAIN:8536` |
| **Username** | Set during install |
| **Password** | Auto-generated during install (displayed in terminal) |

> A real domain name pointing to this server is required for federation with other instances.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8536` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/lemmy/` | All service data and configuration |
| `/root/docker/lemmy/postgres/` | Database storage |
| `/root/docker/lemmy/pictrs/` | Image/media storage |

---

## Management

```bash
# Follow logs
docker logs -f lemmy-ui

# Stop
cd /root/docker/lemmy && docker compose down

# Start
cd /root/docker/lemmy && docker compose up -d

# Update to latest image
cd /root/docker/lemmy && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- A real domain name with DNS A record pointing to this server
- Port 8536/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
