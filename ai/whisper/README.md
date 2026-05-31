# Whisper ASR — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Local speech-to-text REST API powered by OpenAI's Whisper model, supporting 99 languages with no cloud dependency.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Whisper ASR?

Whisper ASR Webservice wraps OpenAI's Whisper model with the faster-whisper engine behind a REST API. It transcribes audio files in 99 languages including Arabic, English, and French. The interactive Swagger UI at `/docs` lets you test the API directly in the browser, and any HTTP client or automation tool can call the `/asr` endpoint. The installer prompts for model size (tiny / base / small / medium / large).

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ai/whisper/whisper-ubuntu.sh
chmod +x whisper-ubuntu.sh
sudo bash whisper-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for model size (tiny / base / small / medium / large)
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **API Endpoint** | `http://SERVER_IP:9000/asr` |
| **API Docs (Swagger)** | `http://SERVER_IP:9000/docs` |
| **Username** | Not required |
| **Password** | Not required |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `9000` | TCP | REST API / Swagger UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/whisper/` | All service data and configuration |
| `/root/docker/whisper/models/` | Downloaded Whisper model files |

---

## Management

```bash
# Follow logs
docker logs -f whisper

# Transcribe an audio file
curl -X POST http://SERVER_IP:9000/asr -F "audio_file=@audio.mp3"

# Stop
cd /root/docker/whisper && docker compose down

# Start
cd /root/docker/whisper && docker compose up -d

# Update to latest image
cd /root/docker/whisper && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 9000/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
