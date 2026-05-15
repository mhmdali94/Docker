# Matrix Synapse + Element Web — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Matrix Synapse](https://matrix.org/) + [Element Web](https://element.io/) — self-hosted federated, end-to-end encrypted messaging. Matrix is an open protocol; Element is the web client. A self-hosted alternative to WhatsApp, Telegram, and Slack.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/communication/matrix/matrix-ubuntu.sh
chmod +x matrix-ubuntu.sh
sudo bash matrix-ubuntu.sh
```

## 🔑 Credentials

No default credentials — register via the Element Web client on first visit.

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8008` | Synapse (Matrix server API) |
| `8009` | Element Web (chat client) |

## 💻 Connect

```bash
# Element Web client (use this to register and chat)
http://SERVER_IP:8009

# Synapse federation API
http://SERVER_IP:8008
```

## ⚙️ Notes

- Register your account via Element Web at port 8009
- Homeserver URL: `http://SERVER_IP:8008`
- For federation with other Matrix servers, a valid domain and reverse proxy with TLS are required

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
