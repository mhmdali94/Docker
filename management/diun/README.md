# Diun — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Diun](https://crazymax.dev/diun/) — Docker image update notifications — no UI, pure notifications.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/management/diun/diun-ubuntu.sh
chmod +x diun-ubuntu.sh
sudo bash diun-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `—` | None (notification agent) |

## 💻 Connect

```bash
docker logs -f diun
```

## 📝 Notes

- Pair with the Gotify or ntfy script: set `DIUN_NOTIF_GOTIFY_ENDPOINT` and token env vars.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
