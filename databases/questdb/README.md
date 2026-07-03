# QuestDB — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [QuestDB](https://questdb.io) — a high-performance time-series database with SQL.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/databases/questdb/questdb-ubuntu.sh
chmod +x questdb-ubuntu.sh
sudo bash questdb-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| PGWire | `admin` / `quest` (defaults) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `9008` | Web console |
| `8812` | PostgreSQL wire |
| `9011` | InfluxDB line protocol |

## 💻 Connect

```bash
http://SERVER_IP:9008
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
