# Cal.com — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Cal.com](https://cal.com) — the open-source Calendly alternative for scheduling.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/calcom/calcom-ubuntu.sh
chmod +x calcom-ubuntu.sh
sudo bash calcom-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `3011` | Web UI |

## 💻 Connect

```bash
http://SERVER_IP:3011
```

## 📝 Notes

- First start runs migrations and may take several minutes.
- Configure SMTP env vars for email notifications in production.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
