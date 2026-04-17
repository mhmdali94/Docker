# MariaDB — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [MariaDB](https://mariadb.org/) — a community-developed relational database, drop-in replacement for MySQL.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/databases/mariadb/mariadb-ubuntu.sh
chmod +x mariadb-ubuntu.sh
sudo bash mariadb-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Root Password | Auto-generated (shown at install) |
| Database User | `dbuser` |
| User Password | Auto-generated (shown at install) |
| Database | `appdb` |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `3306` | MariaDB / MySQL |

## 💻 Connect

```bash
# Connect via Docker
docker exec -it mariadb mysql -u dbuser -p appdb

# Connect from host
mysql -h SERVER_IP -P 3306 -u dbuser -p appdb
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
