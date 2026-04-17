# Nextcloud — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Nextcloud](https://nextcloud.com/) — a self-hosted cloud platform for files, calendar, contacts, talk, and 300+ apps.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/files/nextcloud/nextcloud-ubuntu.sh
chmod +x nextcloud-ubuntu.sh
sudo bash nextcloud-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8080` | Nextcloud Web UI |

## 💻 Connect

```bash
# Web UI
http://SERVER_IP:8080

# Desktop sync client
# Server address: http://SERVER_IP:8080

# WebDAV
http://SERVER_IP:8080/remote.php/dav/files/admin/
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
