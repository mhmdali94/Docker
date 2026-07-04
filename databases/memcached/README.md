# Memcached — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Memcached](https://memcached.org) — the classic high-performance in-memory object cache.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/databases/memcached/memcached-ubuntu.sh
chmod +x memcached-ubuntu.sh
sudo bash memcached-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `11211` | Memcached protocol |

## 💻 Connect

```bash
echo stats | nc SERVER_IP 11211
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
