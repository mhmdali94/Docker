# Infisical — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Open-source secrets management platform — centralize environment variables and API keys with access control and audit logs.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Infisical?

Infisical is an open-source secrets management platform that centralizes environment variables, API keys, and credentials across projects and environments. It provides fine-grained access control, audit logs, secret versioning, dynamic secrets, and SDKs for Node.js, Python, Go, and more. A self-hosted alternative to HashiCorp Vault and Doppler.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/infisical/infisical-ubuntu.sh
chmod +x infisical-ubuntu.sh
sudo bash infisical-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:8090` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8090` | TCP | Web UI / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/infisical/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f infisical

# Stop the service
cd /root/docker/infisical && docker compose down

# Start the service
cd /root/docker/infisical && docker compose up -d

# Update to latest image
cd /root/docker/infisical && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 8090/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
