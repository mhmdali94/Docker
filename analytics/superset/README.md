# Apache Superset — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Apache Superset](https://superset.apache.org) — a modern data exploration and BI visualization platform.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/analytics/superset/superset-ubuntu.sh
chmod +x superset-ubuntu.sh
sudo bash superset-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8143` | Web UI |

## 💻 Connect

```bash
http://SERVER_IP:8143
```

## 📝 Notes

- Demo uses the embedded SQLite metadata DB — fine for evaluation, use Postgres for real use.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
