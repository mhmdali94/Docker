# Woodpecker CI — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Simple, powerful CI/CD engine with YAML pipeline definitions and Docker-native execution.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Woodpecker CI?

Woodpecker CI is a lightweight, open-source continuous integration and delivery system forked from Drone. It uses YAML pipeline definitions similar to GitHub Actions, runs pipeline steps in Docker containers, and integrates with Gitea, GitHub, and GitLab via OAuth. Minimal resource usage and simple configuration make it ideal for self-hosted teams.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/woodpecker/woodpecker-ubuntu.sh
chmod +x woodpecker-ubuntu.sh
sudo bash woodpecker-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:8093` |
| **Login** | Via OAuth (Gitea / GitHub / GitLab) |
| **Agent Secret** | Auto-generated (shown at install) |

> Replace `SERVER_IP` with your server's IP address. Configure an OAuth provider in `/root/docker/woodpecker/docker-compose.yml` before logging in.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8093` | TCP | Web UI |
| `9003` | TCP | Agent gRPC (internal) |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/woodpecker/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f woodpecker-server

# Stop the service
cd /root/docker/woodpecker && docker compose down

# Start the service
cd /root/docker/woodpecker && docker compose up -d

# Update to latest image
cd /root/docker/woodpecker && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 8093/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
