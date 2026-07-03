# TheHive — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [TheHive](https://thehive-project.org) — a scalable security incident response platform.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/security/thehive/thehive-ubuntu.sh
chmod +x thehive-ubuntu.sh
sudo bash thehive-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Email | `admin@thehive.local` |
| Password | `secret` (change immediately) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `9014` | Web UI |

## 💻 Connect

```bash
http://SERVER_IP:9014
```

## 📝 Notes

- Requires at least 8 GB RAM — Cassandra and Elasticsearch are memory-hungry.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
