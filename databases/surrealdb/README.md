# SurrealDB — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [SurrealDB](https://surrealdb.com) — a multi-model database (document, graph, vector) with SQL-like queries.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/databases/surrealdb/surrealdb-ubuntu.sh
chmod +x surrealdb-ubuntu.sh
sudo bash surrealdb-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `root` |
| Password | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8149` | HTTP/WebSocket API |

## 💻 Connect

```bash
surreal sql --endpoint http://SERVER_IP:8149 -u root -p PASSWORD
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
