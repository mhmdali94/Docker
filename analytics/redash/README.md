# Redash — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Redash](https://redash.io/) — open-source data visualization and dashboarding tool. Write SQL queries, build charts, and share dashboards from any data source.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/analytics/redash/redash-ubuntu.sh
chmod +x redash-ubuntu.sh
sudo bash redash-ubuntu.sh
```

## 🔑 Credentials

No default credentials — complete setup at `/setup` on first visit.

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `5001` | Redash Web UI |

## 💻 Connect

```bash
# Web UI (first-time setup)
http://SERVER_IP:5001/setup

# Web UI (after setup)
http://SERVER_IP:5001
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
