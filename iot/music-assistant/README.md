# Music Assistant — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Music Assistant](https://www.music-assistant.io) — a multi-room music library manager that bridges streaming services and speakers.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/iot/music-assistant/music-assistant-ubuntu.sh
chmod +x music-assistant-ubuntu.sh
sudo bash music-assistant-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8298` | Web UI |

## 💻 Connect

```bash
http://SERVER_IP:8298
```

## 📝 Notes

- For local speaker auto-discovery (Sonos, Chromecast, DLNA) replace the ports mapping with `network_mode: host` — the UI then runs on port 8095.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
