# Apprise API — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Apprise API](https://github.com/caronc/apprise-api) — one API to send notifications to almost every notification service in existence.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/communication/apprise/apprise-ubuntu.sh
chmod +x apprise-ubuntu.sh
sudo bash apprise-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8189` | Web UI + API |

## 💻 Connect

```bash
curl -X POST -d 'body=Hello' http://SERVER_IP:8189/notify/apprise
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
