# Pixelfed — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Pixelfed is a federated photo sharing platform (Instagram alternative) that connects with Mastodon and the wider Fediverse via ActivityPub.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Pixelfed?

Pixelfed is a decentralized image-sharing platform built on ActivityPub federation. Users can share photos, follow accounts on other Fediverse servers, and interact with Mastodon users. It supports stories, collections, direct messages, and has an Instagram-like interface. A real domain name is required for federation.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/social/pixelfed/pixelfed-ubuntu.sh
chmod +x pixelfed-ubuntu.sh
sudo bash pixelfed-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for your domain name
- Generates secure credentials
- Starts Pixelfed with MySQL and Redis

---

## Access

| | |
|---|---|
| **Web UI** | `http://YOUR_DOMAIN:8085` |
| **Username** | Register via the web UI |
| **Password** | Register via the web UI |

> A real domain name pointing to this server is required for federation.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8085` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/pixelfed/` | All service data and configuration |
| `/root/docker/pixelfed/storage/` | Uploaded photos and media |
| `/root/docker/pixelfed/mysql/` | Database storage |

---

## Management

```bash
# Follow logs
docker logs -f pixelfed

# Stop
cd /root/docker/pixelfed && docker compose down

# Start
cd /root/docker/pixelfed && docker compose up -d

# Update to latest image
cd /root/docker/pixelfed && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- A real domain name with DNS A record pointing to this server
- Port 8085/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
