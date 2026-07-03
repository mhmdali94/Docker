# TeslaMate — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [TeslaMate](https://docs.teslamate.org) — a powerful self-hosted data logger for your Tesla.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/iot/teslamate/teslamate-ubuntu.sh
chmod +x teslamate-ubuntu.sh
sudo bash teslamate-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `4321` | Web UI |

## 💻 Connect

```bash
http://SERVER_IP:4321
```

## 📝 Notes

- Generate Tesla API tokens with a third-party tool and paste them on first login.
- Grafana dashboards: connect your existing Grafana to the teslamate Postgres DB.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
