# PostgreSQL — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [PostgreSQL](https://www.postgresql.org/) — a powerful, open source object-relational database system.

**Made by:** [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
chmod +x postgres-ubuntu.sh
sudo bash postgres-ubuntu.sh
```

## 🔑 Credentials

The script **auto-generates a secure password**. Connection details are shown at the end of setup. Save them!

| Field | Value |
|-------|-------|
| **User** | `pgadmin` |
| **Database** | `pgdb` |
| **Password** | *(auto-generated)* |
| **Port** | `5432` |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `5432` | PostgreSQL |

## 💻 Connect

```bash
psql -h <server-ip> -U pgadmin -d pgdb
```

---
**Made by [prismatechwork.com](https://prismatechwork.com)**
