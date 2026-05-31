# Mailu — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Simple, full-featured self-hosted email server with Roundcube webmail and Rspamd antispam.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Mailu?

Mailu is a simple yet full-featured self-hosted mail server designed for easy setup and maintenance. It bundles Postfix (SMTP), Dovecot (IMAP), Roundcube webmail, Rspamd antispam with DKIM, and an admin panel — all configured via a single `.env` file. Supports optional Let's Encrypt TLS.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/email/mailu/mailu-ubuntu.sh
chmod +x mailu-ubuntu.sh
sudo bash mailu-ubuntu.sh
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
| **Admin UI** | `http://SERVER_IP/admin` |
| **Webmail (Roundcube)** | `http://SERVER_IP/roundcube` |
| **Username** | `admin@example.com` |
| **Password** | Auto-generated (shown at install) — change immediately |

> Replace `SERVER_IP` with your server's IP address. Proper DNS records (MX, SPF, DKIM, DMARC) required for real email delivery.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `80` / `443` | TCP | Web UI |
| `25` | TCP | SMTP (incoming) |
| `587` | TCP | SMTP submission |
| `465` | TCP | SMTPS |
| `143` | TCP | IMAP |
| `993` | TCP | IMAPS |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/mailu/` | All service data and configuration |

---

## Management

```bash
# Follow logs
cd /root/docker/mailu && docker compose logs -f

# Stop the service
cd /root/docker/mailu && docker compose down

# Start the service
cd /root/docker/mailu && docker compose up -d

# Update to latest image
cd /root/docker/mailu && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 80/tcp, 443/tcp, 25/tcp, 587/tcp, 465/tcp, 143/tcp, 993/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
