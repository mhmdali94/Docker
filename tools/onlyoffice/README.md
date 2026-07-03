# OnlyOffice Document Server — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [OnlyOffice Document Server](https://www.onlyoffice.com) — a self-hosted online office suite (integrates with Nextcloud, Seafile).

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/onlyoffice/onlyoffice-ubuntu.sh
chmod +x onlyoffice-ubuntu.sh
sudo bash onlyoffice-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| JWT Secret | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8110` | Document Server API/UI |

## 💻 Connect

```bash
http://SERVER_IP:8110
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
