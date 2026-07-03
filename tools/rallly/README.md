# Rallly — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Rallly](https://rallly.co) — a Doodle-style meeting poll and scheduling tool.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/rallly/rallly-ubuntu.sh
chmod +x rallly-ubuntu.sh
sudo bash rallly-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `3012` | Web UI |

## 💻 Connect

```bash
http://SERVER_IP:3012
```

## 📝 Notes

- Login uses email magic links — configure SMTP (SMTP_HOST etc.) in docker-compose.yml for full functionality.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
