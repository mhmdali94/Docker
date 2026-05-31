# Gitea — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Lightweight, self-hosted Git service with issues, pull requests, CI/CD hooks, and a web UI — a self-hosted GitHub alternative.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Gitea?

Gitea is a painless, self-hosted Git service written in Go. It provides a GitHub-like interface with repositories, issues, pull requests, project boards, CI/CD integration, webhooks, and user management. Extremely lightweight — runs comfortably on a Raspberry Pi — and a full alternative to GitHub or GitLab for smaller teams.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/gitea/gitea-ubuntu.sh
chmod +x gitea-ubuntu.sh
sudo bash gitea-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:3100` |
| **Username** | Created via setup wizard on first visit |
| **Password** | Created via setup wizard on first visit |

> Replace `SERVER_IP` with your server's IP address. SSH clone: `git clone ssh://git@SERVER_IP:2222/user/repo.git`

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3100` | TCP | Web UI |
| `2222` | TCP | Git SSH |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/gitea/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f gitea

# Stop the service
cd /root/docker/gitea && docker compose down

# Start the service
cd /root/docker/gitea && docker compose up -d

# Update to latest image
cd /root/docker/gitea && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 3100/tcp, 2222/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
