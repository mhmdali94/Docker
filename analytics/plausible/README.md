# Plausible Analytics — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Plausible Analytics](https://plausible.io/) — a lightweight, open-source, privacy-friendly Google Analytics alternative backed by Postgres and ClickHouse.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/analytics/plausible/plausible-ubuntu.sh
chmod +x plausible-ubuntu.sh
sudo bash plausible-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Admin account | Created on first visit |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8100` | Plausible Web UI |

## 💻 Connect

```bash
# Web UI
http://SERVER_IP:8100

# Embed tracking script in your website
<script defer data-domain="yourdomain.com" src="http://SERVER_IP:8100/js/script.js"></script>
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
