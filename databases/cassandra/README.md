# Cassandra — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Cassandra](https://cassandra.apache.org) — the wide-column NoSQL database built for scale.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/databases/cassandra/cassandra-ubuntu.sh
chmod +x cassandra-ubuntu.sh
sudo bash cassandra-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `9042` | CQL native protocol |

## 💻 Connect

```bash
docker exec -it cassandra cqlsh
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
