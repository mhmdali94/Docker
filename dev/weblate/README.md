# Weblate — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Web-based translation management platform with Git integration, translation memory, and machine translation support.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Weblate?

Weblate is an open-source translation management platform that lets translators work on application strings directly in the browser. It integrates with Git, GitHub, and GitLab — translation changes auto-commit back to the repository. Supports translation memory, machine translation (DeepL, LibreTranslate, Google), glossaries, and 60+ file formats including PO, XLIFF, JSON, and iOS Strings.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/weblate/weblate-ubuntu.sh
chmod +x weblate-ubuntu.sh
sudo bash weblate-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:8003` |
| **Email** | Set during install |
| **Password** | Auto-generated (shown at install) |

> Replace `SERVER_IP` with your server's IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8003` | TCP | Web UI / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/weblate/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f weblate

# Stop the service
cd /root/docker/weblate && docker compose down

# Start the service
cd /root/docker/weblate && docker compose up -d

# Update to latest image
cd /root/docker/weblate && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 8003/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
