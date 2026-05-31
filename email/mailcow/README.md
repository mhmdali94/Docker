# Mailcow — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Full-featured self-hosted email suite — Postfix, Dovecot, SOGo webmail, Rspamd antispam, and a web admin panel.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Mailcow?

Mailcow is a complete self-hosted email server suite that bundles all components needed to run a full mail server: Postfix (SMTP), Dovecot (IMAP/POP3), SOGo webmail with CalDAV/CardDAV, Rspamd antispam with DKIM signing, ClamAV antivirus, and a web admin panel for managing domains and mailboxes. Supports Let's Encrypt SSL and two-factor authentication.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/email/mailcow/mailcow-ubuntu.sh
chmod +x mailcow-ubuntu.sh
sudo bash mailcow-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure credentials
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Admin UI** | `https://SERVER_IP` |
| **Webmail (SOGo)** | `https://SERVER_IP/SOGo` |
| **Username** | `admin` |
| **Password** | `moohoo` — **change immediately after first login** |

> Replace `SERVER_IP` with your server's IP address. Proper DNS records (MX, SPF, DKIM, DMARC) are required for real email delivery.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `80` / `443` | TCP | Web UI (HTTP/HTTPS) |
| `25` | TCP | SMTP (incoming) |
| `587` | TCP | SMTP submission (outgoing) |
| `465` | TCP | SMTPS |
| `143` | TCP | IMAP |
| `993` | TCP | IMAPS |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/mailcow/` | All service data and configuration |

---

## Management

```bash
# Follow logs
cd /root/docker/mailcow/mailcow-dockerized && docker compose logs -f

# Stop the service
cd /root/docker/mailcow/mailcow-dockerized && docker compose down

# Start the service
cd /root/docker/mailcow/mailcow-dockerized && docker compose up -d

# Update
cd /root/docker/mailcow/mailcow-dockerized && ./update.sh
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 80/tcp, 443/tcp, 25/tcp, 587/tcp, 465/tcp, 143/tcp, 993/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
