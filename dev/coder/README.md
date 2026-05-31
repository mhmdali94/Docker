# Coder — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Self-hosted cloud development environments — provision workspaces on Docker, Kubernetes, or cloud VMs.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Coder?

Coder is an open-source platform for self-hosted cloud development environments. Teams define workspace templates (Docker, Kubernetes, VM) and developers provision their own fully-configured development machines on demand. Features include VS Code and JetBrains IDE support, port forwarding, shared terminals, and resource usage tracking.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/coder/coder-ubuntu.sh
chmod +x coder-ubuntu.sh
sudo bash coder-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:3020` |
| **Username** | `admin` |
| **Password** | Auto-generated (shown at install) |

> Replace `SERVER_IP` with your server's IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3020` | TCP | Web UI / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/coder/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f coder

# Stop the service
cd /root/docker/coder && docker compose down

# Start the service
cd /root/docker/coder && docker compose up -d

# Update to latest image
cd /root/docker/coder && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 3020/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
