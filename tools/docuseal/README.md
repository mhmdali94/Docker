# DocuSeal — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

DocuSeal is an open-source document signing platform for creating PDF forms, collecting legally binding e-signatures, and managing signing workflows.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is DocuSeal?

DocuSeal is a self-hosted alternative to DocuSign and HelloSign. It allows you to upload PDF documents, define form fields and signature positions, and send them to recipients for electronic signing. It supports templates, audit trails, email notifications, and a REST API for integration.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/docuseal/docuseal-ubuntu.sh
chmod +x docuseal-ubuntu.sh
sudo bash docuseal-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Starts the DocuSeal container
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:3008` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3008` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/docuseal/` | All service data and configuration |
| `/root/docker/docuseal/data/` | Documents and database |

---

## Management

```bash
# Follow logs
docker logs -f docuseal

# Stop
cd /root/docker/docuseal && docker compose down

# Start
cd /root/docker/docuseal && docker compose up -d

# Update to latest image
cd /root/docker/docuseal && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 3008/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
