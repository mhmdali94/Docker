# Chatwoot — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Chatwoot](https://www.chatwoot.com/) — open-source customer support and live chat platform. Manage conversations from email, live chat, social media, and API in one unified inbox. A self-hosted Intercom alternative.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/communication/chatwoot/chatwoot-ubuntu.sh
chmod +x chatwoot-ubuntu.sh
sudo bash chatwoot-ubuntu.sh
```

## 🔑 Credentials

No default credentials — create your admin account at `/auth/sign_up` on first visit.

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `3008` | Chatwoot Web UI |

## 💻 Connect

```bash
# First-time signup
http://SERVER_IP:3008/auth/sign_up

# Web UI (after setup)
http://SERVER_IP:3008
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
