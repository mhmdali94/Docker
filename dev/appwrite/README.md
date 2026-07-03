# Appwrite — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Appwrite](https://appwrite.io) — the open-source backend-as-a-service (auth, databases, functions, storage).

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/appwrite/appwrite-ubuntu.sh
chmod +x appwrite-ubuntu.sh
sudo bash appwrite-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Console admin | Created on first visit |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8201` | Console + API (HTTP) |
| `8448` | HTTPS |

## 💻 Connect

```bash
http://SERVER_IP:8201
```

## 📝 Notes

- Uses the official Appwrite installer (non-interactive) — ~15 containers, 4 GB+ RAM.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
