# Owncast — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Owncast](https://owncast.online) — your own self-hosted live streaming server (Twitch alternative).

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/media/owncast/owncast-ubuntu.sh
chmod +x owncast-ubuntu.sh
sudo bash owncast-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Admin user | `admin` |
| Password | `abc123` (change in admin → integrations) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8280` | Web UI |
| `1935` | RTMP ingest |

## 💻 Connect

```bash
http://SERVER_IP:8280
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
