# Vaultwarden

Lightweight self-hosted Bitwarden-compatible password manager server.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

---

## 🚀 Quick Install

```bash
wget https://raw.githubusercontent.com/yourusername/docker/main/security/vaultwarden/vaultwarden-ubuntu.sh
sudo bash vaultwarden-ubuntu.sh
```

Or:

```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/docker/main/security/vaultwarden/vaultwarden-ubuntu.sh | sudo bash
```

---

## 📖 What is Vaultwarden?

Vaultwarden is an unofficial, lightweight Bitwarden server implementation written in Rust. It is fully compatible with all official Bitwarden clients (browser extensions, mobile apps, desktop apps) and uses a fraction of the resources of the official server.

## ✨ Features

- Compatible with all official Bitwarden clients
- Password vault with folders and collections
- Secure notes, credit cards, and identity storage
- Password generator
- Two-factor authentication (TOTP, YubiKey, FIDO2)
- Organization and sharing support
- Admin panel for user management
- Uses very little memory (~10MB RAM)

## 🌐 Access

| Vault URL | `http://<server-ip>:8086` |
|-----------|--------------------------|
| Admin Panel | `http://<server-ip>:8086/admin` |
| Admin Token | Auto-generated during install (shown in terminal) |

## ⚙️ Setup Steps

1. Run the installer
2. Open `http://<server-ip>:8086` and create your account
3. Install the **Bitwarden** browser extension or mobile app
4. Change the server URL in the app to `http://<server-ip>:8086`
5. Log in with your account

## 🔌 Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8086` | TCP | Vaultwarden Web Vault + API |

## 📁 Directory Structure

```
/root/docker/vaultwarden/
├── docker-compose.yml
└── data/          # Vault database & attachments
```

## 📚 Documentation

- [Vaultwarden GitHub](https://github.com/dani-garcia/vaultwarden)
- [Bitwarden Clients](https://bitwarden.com/download)

---

**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
