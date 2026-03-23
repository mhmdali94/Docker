# Redis — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Redis](https://redis.io/) — an in-memory data store used as a database, cache, and message broker.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
chmod +x redis-ubuntu.sh
sudo bash redis-ubuntu.sh
```

## 🔑 Credentials

The script **auto-generates a secure password**. It is shown at the end of the setup. Save it!

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `6379` | Redis |

## 💻 Connect

```bash
redis-cli -h <server-ip> -p 6379 -a <generated-password>
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
