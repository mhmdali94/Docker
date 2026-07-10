# Collabora Online — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Collabora Online](https://www.collaboraonline.com) — LibreOffice in the browser — the collaborative office suite for Nextcloud/OpenCloud/Seafile.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/collabora/collabora-ubuntu.sh
chmod +x collabora-ubuntu.sh
sudo bash collabora-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Admin | `admin` / auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `9980` | WOPI + admin |

## 💻 Connect

```bash
http://SERVER_IP:9980/hosting/discovery
```

## 📝 Notes

- `aliasgroup1` is preset for a Nextcloud on port 8080 — adjust it to your file server's URL.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
