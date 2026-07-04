# FerretDB — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [FerretDB](https://www.ferretdb.com) — a truly open-source MongoDB alternative backed by PostgreSQL.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/databases/ferretdb/ferretdb-ubuntu.sh
chmod +x ferretdb-ubuntu.sh
sudo bash ferretdb-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `ferret` |
| Password | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `27018` | MongoDB wire protocol |

## 💻 Connect

```bash
mongosh mongodb://ferret:PASSWORD@SERVER_IP:27018/
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
