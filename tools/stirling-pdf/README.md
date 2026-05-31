# Stirling-PDF — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Stirling-PDF is a powerful self-hosted web application with 50+ PDF tools — merge, split, compress, convert, OCR, sign, and more. All processing done locally.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Stirling-PDF?

Stirling-PDF provides a comprehensive suite of PDF manipulation tools through a clean web interface. All file processing happens locally on your server — no files are uploaded to any third-party service. It supports merging, splitting, rotating, compressing, watermarking, OCR text extraction, PDF-to-image conversion, digital signatures, and over 50 more operations. No login is required to use any feature.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/stirling-pdf/stirling-pdf-ubuntu.sh
chmod +x stirling-pdf-ubuntu.sh
sudo bash stirling-pdf-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:8087` |
| **Login** | None (open by default) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8087` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/stirling-pdf/` | All service data and configuration |
| `/root/docker/stirling-pdf/configs/` | App configuration |
| `/root/docker/stirling-pdf/logs/` | Application logs |

---

## Management

```bash
# Follow logs
docker logs -f stirling-pdf

# Stop
cd /root/docker/stirling-pdf && docker compose down

# Start
cd /root/docker/stirling-pdf && docker compose up -d

# Update to latest image
cd /root/docker/stirling-pdf && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8087/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
