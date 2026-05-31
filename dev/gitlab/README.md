# GitLab CE — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Complete DevOps platform — Git hosting, CI/CD pipelines, container registry, issue tracker, and merge requests in one container.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is GitLab CE?

GitLab Community Edition is a complete open-source DevOps platform providing Git repository hosting, CI/CD pipelines, a container registry, issue tracking, merge requests, wiki, and project boards — all in a single self-hosted application. Used by thousands of organizations as an alternative to GitHub or Azure DevOps.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/gitlab/gitlab-ubuntu.sh
chmod +x gitlab-ubuntu.sh
sudo bash gitlab-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:9080` |
| **Username** | `root` |
| **Password** | Auto-generated (shown at install) |

> Replace `SERVER_IP` with your server's IP address. First startup takes 3-5 minutes. Minimum 4 GB RAM required.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `9080` | TCP | Web UI (HTTP) |
| `9443` | TCP | Web UI (HTTPS) |
| `2222` | TCP | Git SSH |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/gitlab/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f gitlab

# Stop the service
cd /root/docker/gitlab && docker compose down

# Start the service
cd /root/docker/gitlab && docker compose up -d

# Update to latest image
cd /root/docker/gitlab && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Minimum 4 GB RAM (8 GB recommended)
- Ports open in firewall: 9080/tcp, 9443/tcp, 2222/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
