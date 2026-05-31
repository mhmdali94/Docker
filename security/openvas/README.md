# OpenVAS / Greenbone — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

OpenVAS (Greenbone Vulnerability Scanner) is a full-featured network vulnerability scanner that detects CVEs, misconfigurations, and security weaknesses across your infrastructure.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is OpenVAS?

OpenVAS is part of the Greenbone Vulnerability Management (GVM) framework. It performs authenticated and unauthenticated network scans against hosts and services, detects thousands of CVEs, and generates detailed vulnerability reports. It is widely used for infrastructure security audits and compliance assessments.

> **Important:** First startup takes 15–30 minutes for NVT feed synchronization. The web UI will not be available until synchronization completes.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/security/openvas/openvas-ubuntu.sh
chmod +x openvas-ubuntu.sh
sudo bash openvas-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure credentials
- Starts the OpenVAS container
- Waits for NVT feed synchronization

---

## Access

| | |
|---|---|
| **Web UI** | `https://SERVER_IP:9392` (HTTPS, accept SSL warning) |
| **Username** | `admin` |
| **Password** | Auto-generated during install (displayed in terminal) |

> Replace `SERVER_IP` with your server's actual IP address.
> If the UI is not yet available, wait 15–30 minutes for the NVT feed sync to complete: `docker logs openvas`

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `9392` | TCP | HTTPS Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/openvas/` | All service data and configuration |
| `/root/docker/openvas/data/` | NVT feeds and scan data |

---

## Management

```bash
# Follow logs (monitor feed sync progress)
docker logs -f openvas

# Stop
cd /root/docker/openvas && docker compose down

# Start
cd /root/docker/openvas && docker compose up -d

# Update to latest image
cd /root/docker/openvas && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 9392/tcp open in firewall
- At least 4 GB RAM recommended

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
