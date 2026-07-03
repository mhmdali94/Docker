# Bagisto — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Bagisto](https://bagisto.com) — a Laravel-based open-source e-commerce platform (popular in the Laravel/MENA community).

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ecommerce/bagisto/bagisto-ubuntu.sh
chmod +x bagisto-ubuntu.sh
sudo bash bagisto-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Email | `admin@example.com` |
| Password | `admin123` (change immediately) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8198` | Storefront + admin |

## 💻 Connect

```bash
http://SERVER_IP:8198
```

## 📝 Notes

- The upstream image ships with fixed database credentials — strictly a demo/lab setup.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
