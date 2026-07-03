# InvenTree — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [InvenTree](https://inventree.org) — open-source inventory management for parts, stock and BOMs.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/erp/inventree/inventree-ubuntu.sh
chmod +x inventree-ubuntu.sh
sudo bash inventree-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8152` | Web UI |

## 💻 Connect

```bash
http://SERVER_IP:8152
```

## 📝 Notes

- Demo runs with INVENTREE_DEBUG=true so static files are served without a proxy — front it with a reverse proxy for real use.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
