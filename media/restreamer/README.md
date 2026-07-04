# Restreamer — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Restreamer](https://datarhei.github.io/restreamer/) — receive a video stream and restream it to YouTube, Twitch and more simultaneously.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/media/restreamer/restreamer-ubuntu.sh
chmod +x restreamer-ubuntu.sh
sudo bash restreamer-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8282` | Web UI |
| `1936` | RTMP ingest |

## 💻 Connect

```bash
http://SERVER_IP:8282
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
