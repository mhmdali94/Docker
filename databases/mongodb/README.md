# MongoDB — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [MongoDB](https://www.mongodb.com/) — a document-oriented NoSQL database.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/databases/mongodb/mongodb-ubuntu.sh
chmod +x mongodb-ubuntu.sh
sudo bash mongodb-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | Auto-generated (shown at install) |
| Auth DB | `admin` |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `27017` | MongoDB |

## 💻 Connect

```bash
# Connect via Docker
docker exec -it mongodb mongosh -u admin -p --authenticationDatabase admin

# Connection string
mongodb://admin:PASSWORD@SERVER_IP:27017/
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
