# Listmonk

High-performance self-hosted newsletter and mailing list manager with a modern web UI.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

---

## 🚀 Quick Install

```bash
wget https://raw.githubusercontent.com/yourusername/docker/main/email/listmonk/listmonk-ubuntu.sh
sudo bash listmonk-ubuntu.sh
```

Or:

```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/docker/main/email/listmonk/listmonk-ubuntu.sh | sudo bash
```

---

## 📖 What is Listmonk?

Listmonk is a fast, self-hosted newsletter and mailing list manager. It is **not** a full email server — it requires an external SMTP service (like Gmail SMTP, AWS SES, Postmark, Mailgun) to actually send emails. It provides a powerful dashboard for managing subscribers, campaigns, and analytics.

## ✨ Features

- Manage multiple mailing lists and subscribers
- Create and send HTML/plain-text newsletters
- Campaign analytics (open rates, click rates)
- Transactional email support
- Subscriber import/export via CSV
- Template system for emails
- REST API
- Powered by PostgreSQL

## 🌐 Access

| URL | `http://<server-ip>:9000` |
|-----|--------------------------|
| Username | `admin` |
| Password | Auto-generated during install (shown in terminal) |

## 🔌 Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `9000` | TCP | Listmonk Web UI |

## ⚙️ Configure SMTP

After install, go to **Settings → SMTP** and add your SMTP provider:
- Gmail SMTP
- AWS SES
- Postmark
- Mailgun
- Or any custom SMTP server

## 📁 Directory Structure

```
/root/docker/listmonk/
├── docker-compose.yml
├── config.toml      # App configuration
├── uploads/         # Media uploads
└── pgdata/          # PostgreSQL data
```

## 📚 Documentation

- [Listmonk Documentation](https://listmonk.app/docs)
- [Listmonk GitHub](https://github.com/knadh/listmonk)

---

**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
