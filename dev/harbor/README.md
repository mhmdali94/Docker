# Harbor — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Open-source container registry with vulnerability scanning, RBAC, replication, and a web UI.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Harbor?

Harbor is a CNCF-graduated open-source container registry that extends Docker Distribution with security and management features. It provides role-based access control, image vulnerability scanning (via Trivy), replication between registries, webhook notifications, and a web UI for managing images and projects. A self-hosted alternative to Docker Hub or AWS ECR.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/harbor/harbor-ubuntu.sh
chmod +x harbor-ubuntu.sh
sudo bash harbor-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:5080` |
| **Username** | `admin` |
| **Password** | Auto-generated (shown at install) |

> Replace `SERVER_IP` with your server's IP address. Docker login: `docker login SERVER_IP:5080`

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `5080` | TCP | Web UI / Registry API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/harbor/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f harbor-core

# Stop the service
cd /root/docker/harbor && docker compose down

# Start the service
cd /root/docker/harbor && docker compose up -d

# Update to latest image
cd /root/docker/harbor && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 5080/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
