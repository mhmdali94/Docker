# Xibo — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Xibo](https://xibosignage.com) — open-source digital signage — manage displays, layouts and schedules.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/signage/xibo/xibo-ubuntu.sh
chmod +x xibo-ubuntu.sh
sudo bash xibo-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `xibo_admin` |
| Password | `password` (change immediately) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8320` | CMS Web UI |
| `9505` | XMR (player messaging) |

## 💻 Connect

```bash
http://SERVER_IP:8320
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
