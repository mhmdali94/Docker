# addy.io (AnonAddy) — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [addy.io (AnonAddy)](https://addy.io) — anonymous email forwarding — create unlimited aliases on your own domain.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/email/addy/addy-ubuntu.sh
chmod +x addy-ubuntu.sh
sudo bash addy-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8190` | Web UI |
| `25` | Inbound SMTP |

## 💻 Connect

```bash
http://SERVER_IP:8190
```

## 📝 Notes

- Requires MX/SPF/DKIM DNS records and reverse DNS for reliable mail flow.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
