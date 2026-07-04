# ScyllaDB — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [ScyllaDB](https://www.scylladb.com) — a drop-in Cassandra replacement written in C++ — much faster on the same hardware.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/databases/scylladb/scylladb-ubuntu.sh
chmod +x scylladb-ubuntu.sh
sudo bash scylladb-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `9043` | CQL native protocol (mapped from 9042) |

## 💻 Connect

```bash
docker exec -it scylladb cqlsh
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
