# Speaches — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Speaches](https://speaches.ai) — an OpenAI-compatible speech API — transcription (faster-whisper), translation and TTS.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ai/speaches/speaches-ubuntu.sh
chmod +x speaches-ubuntu.sh
sudo bash speaches-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8192` | HTTP API |

## 💻 Connect

```bash
curl http://SERVER_IP:8192/v1/models
```

## 📝 Notes

- CPU image — for GPU acceleration switch the tag to `latest-cuda`.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
