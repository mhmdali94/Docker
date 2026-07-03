# Calibre-Web — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Calibre-Web](https://github.com/janeczku/calibre-web) — a clean web app for browsing, reading and managing your Calibre e-book library.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/media/calibre-web/calibre-web-ubuntu.sh
chmod +x calibre-web-ubuntu.sh
sudo bash calibre-web-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | `admin123` (change immediately) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8131` | Web UI |

## 💻 Connect

```bash
http://SERVER_IP:8131
```

## 📝 Notes

- On first setup, set the Calibre database folder to `/books` (an empty metadata.db is created if missing via the web UI upload).

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
