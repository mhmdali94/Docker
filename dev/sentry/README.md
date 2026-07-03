# Sentry (self-hosted) — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Sentry](https://sentry.io) — application error tracking and performance monitoring.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/sentry/sentry-ubuntu.sh
chmod +x sentry-ubuntu.sh
sudo bash sentry-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Admin | Created after install: `cd /root/docker/sentry && docker compose run --rm web createuser` |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `9002` | Web UI |

## 💻 Connect

```bash
http://SERVER_IP:9002
```

## 📝 Notes

- **Heavy stack:** 40+ containers, requires 16 GB RAM and 20 GB free disk.
- Uses the official `getsentry/self-hosted` installer.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
