# Code-server — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

VS Code running in the browser — full IDE accessible from any device over HTTP.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Code-server?

Code-server is a self-hosted version of Visual Studio Code that runs in the browser. It provides the full VS Code experience including extensions, integrated terminal, Git integration, and IntelliSense — accessible from any device with a browser. The workspace is mounted from the host system.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/code-server/code-server-ubuntu.sh
chmod +x code-server-ubuntu.sh
sudo bash code-server-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:8094` |
| **Password** | Auto-generated (shown at install) |

> Replace `SERVER_IP` with your server's IP address. The workspace is mounted at `/root` inside the container.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8094` | TCP | Web IDE |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/code-server/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f code-server

# Stop the service
cd /root/docker/code-server && docker compose down

# Start the service
cd /root/docker/code-server && docker compose up -d

# Update to latest image
cd /root/docker/code-server && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 8094/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
