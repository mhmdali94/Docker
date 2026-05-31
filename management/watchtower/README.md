# Watchtower — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Watchtower is an automated Docker container updater that monitors your running containers and restarts them with the latest image versions on a configurable schedule.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Watchtower?

Watchtower runs silently as a background daemon, polling Docker Hub (or your private registry) for updated images. When a new version is found, it gracefully stops the container, pulls the new image, and restarts it with the same parameters. Old images are cleaned up automatically. No web UI — it is a pure background service.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/management/watchtower/watchtower-ubuntu.sh
chmod +x watchtower-ubuntu.sh
sudo bash watchtower-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Starts the service stack
- Confirms the daemon is running

---

## Access

| | |
|---|---|
| **Web UI** | None — background daemon only |
| **Update Schedule** | Daily at 04:00 UTC |

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| — | — | No ports exposed (outbound only) |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/watchtower/` | Service configuration |

---

## Management

```bash
# Follow logs
docker logs -f watchtower

# Stop
cd /root/docker/watchtower && docker compose down

# Start
cd /root/docker/watchtower && docker compose up -d

# Update to latest image
cd /root/docker/watchtower && docker compose pull && docker compose up -d
```

To exclude a specific container from automatic updates, add this label to it:

```yaml
labels:
  - "com.centurylinklabs.watchtower.enable=false"
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Outbound internet access for image pulls

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
