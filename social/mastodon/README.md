# Mastodon — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Mastodon is an open-source, federated social network (Twitter/X alternative) that connects with thousands of other instances via the ActivityPub protocol.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Mastodon?

Mastodon is a decentralized microblogging platform where users can post, follow, and interact across a global federation of independent servers. Your instance federates with other Mastodon, Pleroma, and compatible Fediverse servers via ActivityPub. Mastodon requires a real domain name and is resource-intensive for public instances.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/social/mastodon/mastodon-ubuntu.sh
chmod +x mastodon-ubuntu.sh
sudo bash mastodon-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for your domain name
- Generates secure credentials and secrets
- Starts the full Mastodon stack (web, sidekiq, streaming, PostgreSQL, Redis)
- Creates an initial admin account

---

## Access

| | |
|---|---|
| **Web UI** | `http://YOUR_DOMAIN:3005` |
| **Admin Panel** | `http://YOUR_DOMAIN:3005/admin` |
| **Admin Email** | `admin@YOUR_DOMAIN` |
| **Password** | Reset via: `docker exec mastodon-web bash -c "RAILS_ENV=production bundle exec tootctl accounts modify admin --reset-password"` |

> A real domain name pointing to this server is required for federation.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3005` | TCP | Web UI |
| `4000` | TCP | Streaming API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/mastodon/` | All service data and configuration |
| `/root/docker/mastodon/public/system/` | Media uploads |
| `/root/docker/mastodon/postgres/` | Database storage |

---

## Management

```bash
# Follow logs
docker logs -f mastodon-web

# Stop
cd /root/docker/mastodon && docker compose down

# Start
cd /root/docker/mastodon && docker compose up -d

# Update to latest image
cd /root/docker/mastodon && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- A real domain name with DNS A record pointing to this server
- Ports 3005/tcp and 4000/tcp open in firewall
- At least 2 GB RAM recommended

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
