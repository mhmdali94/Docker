# Paperless-NGX — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Paperless-NGX](https://docs.paperless-ngx.com/) — a document management system that transforms physical documents into a searchable online archive.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/files/paperless-ngx/paperless-ngx-ubuntu.sh
chmod +x paperless-ngx-ubuntu.sh
sudo bash paperless-ngx-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8010` | Paperless-NGX Web UI |

## 💻 Connect

```bash
# Web UI
http://SERVER_IP:8010

# Drop documents for auto-import
/root/docker/paperless-ngx/consume/
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
