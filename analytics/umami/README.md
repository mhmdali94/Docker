# Umami — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Umami](https://umami.is/) — a simple, privacy-focused, open-source alternative to Google Analytics.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/analytics/umami/umami-ubuntu.sh
chmod +x umami-ubuntu.sh
sudo bash umami-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | `umami` (**change immediately**) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `3002` | Umami Web UI |

## 💻 Connect

```bash
# Web UI
http://SERVER_IP:3002

# Embed tracking script in your website
<script async src="http://SERVER_IP:3002/script.js" data-website-id="YOUR_WEBSITE_ID"></script>
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
