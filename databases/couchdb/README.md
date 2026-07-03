# CouchDB — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [CouchDB](https://couchdb.apache.org) — a document database that replicates — sync-friendly NoSQL.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/databases/couchdb/couchdb-ubuntu.sh
chmod +x couchdb-ubuntu.sh
sudo bash couchdb-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `5984` | HTTP API + Fauxton UI |

## 💻 Connect

```bash
http://SERVER_IP:5984/_utils
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
