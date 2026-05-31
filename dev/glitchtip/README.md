# GlitchTip — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Sentry-compatible open-source error tracking — collect exceptions, performance metrics, and uptime checks.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is GlitchTip?

GlitchTip is an open-source error tracking platform compatible with the Sentry SDK. It captures and aggregates application errors, exceptions, and performance metrics across multiple projects and languages. Drop in the GlitchTip DSN as a replacement for Sentry without changing your SDK code.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/glitchtip/glitchtip-ubuntu.sh
chmod +x glitchtip-ubuntu.sh
sudo bash glitchtip-ubuntu.sh
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
| **Username** | Register on first visit |
| **Password** | Register on first visit |

> Replace `SERVER_IP` with your server's IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8093` | TCP | Web UI / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/glitchtip/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f glitchtip

# Stop the service
cd /root/docker/glitchtip && docker compose down

# Start the service
cd /root/docker/glitchtip && docker compose up -d

# Update to latest image
cd /root/docker/glitchtip && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 8093/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
