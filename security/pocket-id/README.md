# Pocket ID — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Pocket ID](https://pocket-id.org) — a simple, passkey-first OIDC identity provider.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/security/pocket-id/pocket-id-ubuntu.sh
chmod +x pocket-id-ubuntu.sh
sudo bash pocket-id-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8170` | Web UI + OIDC |

## 💻 Connect

```bash
http://SERVER_IP:8170/setup
```

## 📝 Notes

- Passkeys require HTTPS in most browsers for non-localhost — put a TLS reverse proxy in front for real use.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
