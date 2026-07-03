# DragonflyDB — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [DragonflyDB](https://www.dragonflydb.io) — a modern multithreaded Redis/Memcached replacement.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/databases/dragonfly/dragonfly-ubuntu.sh
chmod +x dragonfly-ubuntu.sh
sudo bash dragonfly-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Password | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `6382` | RESP protocol |

## 💻 Connect

```bash
redis-cli -h SERVER_IP -p 6382 -a PASSWORD
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
