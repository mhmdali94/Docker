# Jitsi Meet — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Self-hosted video conferencing — no accounts needed, share a link and start a meeting instantly.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Jitsi Meet?

Jitsi Meet is an open-source video conferencing platform that requires no account creation. Users click a link, enter a room name, and start a meeting directly in the browser. It supports screen sharing, chat, hand raising, recording, and moderator controls. A self-hosted alternative to Zoom and Google Meet.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/communication/jitsi/jitsi-ubuntu.sh
chmod +x jitsi-ubuntu.sh
sudo bash jitsi-ubuntu.sh
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
| **Web UI (HTTP)** | `http://SERVER_IP:8080` |
| **Web UI (HTTPS)** | `https://SERVER_IP:8443` |
| **Username** | None required |
| **Password** | None required (room passwords optional) |

> Replace `SERVER_IP` with your server's IP address. A public IP is required for remote participants to connect via the media bridge.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8080` | TCP | Web UI (HTTP) |
| `8443` | TCP | Web UI (HTTPS) |
| `10000` | UDP | Media (video/audio) |
| `4443` | TCP | Media fallback |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/jitsi/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f jitsi-web

# Stop the service
cd /root/docker/jitsi && docker compose down

# Start the service
cd /root/docker/jitsi && docker compose up -d

# Update to latest image
cd /root/docker/jitsi && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Public IP address (required for remote participants)
- Ports open in firewall: 8080/tcp, 8443/tcp, 10000/udp, 4443/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
