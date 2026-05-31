# LibreTranslate — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

LibreTranslate is a free and open-source machine translation API — a self-hosted alternative to Google Translate and DeepL with support for 30+ languages.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is LibreTranslate?

LibreTranslate runs an offline machine translation engine (Argos Translate) and exposes a simple REST API compatible with LibreOffice, browsers, and custom integrations. This install pre-loads English, Arabic, French, Spanish, German, Chinese, Russian, Japanese, Korean, Portuguese, Turkish, and Italian. First startup downloads language models (~2 GB).

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/libretranslate/libretranslate-ubuntu.sh
chmod +x libretranslate-ubuntu.sh
sudo bash libretranslate-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Starts LibreTranslate (downloads ~2 GB of language models on first start)
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:5010` |
| **API Docs** | `http://SERVER_IP:5010/docs` |
| **Username** | N/A — API key based |
| **Password** | N/A |

> Replace `SERVER_IP` with your server's actual IP address.
> First startup may take several minutes while language models download.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `5010` | TCP | Web UI / REST API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/libretranslate/` | All service data and configuration |
| `/root/docker/libretranslate/data/` | API key database and language model cache |

---

## Management

```bash
# Follow logs (monitor model downloads)
docker logs -f libretranslate

# Stop
cd /root/docker/libretranslate && docker compose down

# Start
cd /root/docker/libretranslate && docker compose up -d

# Update to latest image
cd /root/docker/libretranslate && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 5010/tcp open in firewall
- At least 3 GB free disk space for language models

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
