# Shynet — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Shynet](https://github.com/milesmcc/shynet) — modern, privacy-friendly web analytics without cookies.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/analytics/shynet/shynet-ubuntu.sh
chmod +x shynet-ubuntu.sh
sudo bash shynet-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Admin | Created via `docker exec -it shynet ./manage.py registeradmin you@email.com` |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8233` | Web UI |

## 💻 Connect

```bash
http://SERVER_IP:8233
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
