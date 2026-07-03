# Stalwart Mail Server — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Stalwart Mail Server](https://stalw.art) — a modern all-in-one mail server (JMAP, IMAP4, SMTP) written in Rust, with web admin.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/email/stalwart/stalwart-ubuntu.sh
chmod +x stalwart-ubuntu.sh
sudo bash stalwart-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Admin | Shown in `docker logs stalwart` on first start |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8150` | Web admin |
| `25` | SMTP |
| `465` | SMTPS |
| `587` | Submission |
| `993` | IMAPS |
| `4190` | ManageSieve |

## 💻 Connect

```bash
http://SERVER_IP:8150
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
