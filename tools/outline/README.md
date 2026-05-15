# Outline — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Outline](https://www.getoutline.com/) — fast, collaborative knowledge base and wiki. Real-time editing, Markdown support, nested documents, and granular permissions. A self-hosted Notion alternative.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/outline/outline-ubuntu.sh
chmod +x outline-ubuntu.sh
sudo bash outline-ubuntu.sh
```

## 🔑 Credentials

No default credentials — Outline uses magic-link email login or OAuth providers.

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `3003` | Outline Web UI |

## 💻 Connect

```bash
# Web UI
http://SERVER_IP:3003
```

## ⚙️ Notes

- Outline requires an authentication provider to log in.
- For self-hosted setups, configure SMTP for magic-link login, or set up Slack/Google OAuth in the environment variables.
- After adding SMTP or OAuth config, restart: `docker compose restart outline`

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
