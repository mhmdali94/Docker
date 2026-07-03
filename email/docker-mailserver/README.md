# Docker Mailserver — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Docker Mailserver](https://docker-mailserver.github.io/docker-mailserver/latest/) — a production-ready full-stack mail server (SMTP, IMAP, Rspamd) without a web UI — light on resources.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/email/docker-mailserver/docker-mailserver-ubuntu.sh
chmod +x docker-mailserver-ubuntu.sh
sudo bash docker-mailserver-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Mailboxes | Created via `docker exec -it mailserver setup email add user@domain` |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `25` | SMTP |
| `143` | IMAP |
| `465` | SMTPS |
| `587` | Submission |
| `993` | IMAPS |

## 💻 Connect

```bash
docker exec -it mailserver setup email add user@yourdomain.com
```

## 📝 Notes

- Requires proper DNS (MX, SPF, DKIM, DMARC) and reverse DNS to deliver mail.
- Generate DKIM keys: `docker exec -it mailserver setup config dkim`.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
