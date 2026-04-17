# ntfy — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [ntfy](https://ntfy.sh/) — a simple HTTP-based pub/sub push notification service. Send notifications to your phone or desktop via plain HTTP.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/communication/ntfy/ntfy-ubuntu.sh
chmod +x ntfy-ubuntu.sh
sudo bash ntfy-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Auth | Open (read-write) by default |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8095` | ntfy Web UI & HTTP API |

## 💻 Connect

```bash
# Web UI
http://SERVER_IP:8095

# Publish a message
curl -d "Backup completed!" http://SERVER_IP:8095/alerts

# Subscribe via ntfy app (iOS / Android)
# Server: http://SERVER_IP:8095
# Topic:  alerts
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
