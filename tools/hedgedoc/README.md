# HedgeDoc — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

HedgeDoc is a real-time collaborative Markdown editor where multiple people can write and edit the same document simultaneously.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is HedgeDoc?

HedgeDoc (formerly CodiMD) is a self-hosted, open-source real-time Markdown collaboration tool. Documents are accessible via shareable URLs with no account required, making it ideal for quick meeting notes, shared documentation, and collaborative writing. It renders Markdown live and supports diagrams (Mermaid, PlantUML), math (LaTeX), and code highlighting.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/hedgedoc/hedgedoc-ubuntu.sh
chmod +x hedgedoc-ubuntu.sh
sudo bash hedgedoc-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for your server IP or domain
- Generates secure credentials
- Starts HedgeDoc and PostgreSQL
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:3888` |
| **New Note** | `http://SERVER_IP:3888/new` |
| **Username** | N/A — anonymous editing enabled by default |
| **Password** | N/A |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3888` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/hedgedoc/` | All service data and configuration |
| `/root/docker/hedgedoc/uploads/` | Uploaded images |
| `/root/docker/hedgedoc/postgres/` | Database storage |

---

## Management

```bash
# Follow logs
docker logs -f hedgedoc

# Stop
cd /root/docker/hedgedoc && docker compose down

# Start
cd /root/docker/hedgedoc && docker compose up -d

# Update to latest image
cd /root/docker/hedgedoc && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 3888/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
