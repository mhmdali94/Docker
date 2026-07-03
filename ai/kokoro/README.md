# Kokoro TTS — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Kokoro TTS](https://github.com/remsky/Kokoro-FastAPI) — high-quality local text-to-speech with an OpenAI-compatible API.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ai/kokoro/kokoro-ubuntu.sh
chmod +x kokoro-ubuntu.sh
sudo bash kokoro-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8880` | HTTP API + web player |

## 💻 Connect

```bash
curl http://SERVER_IP:8880/v1/audio/voices
```

## 📝 Notes

- CPU image — switch tag to `latest-gpu` for NVIDIA acceleration.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
