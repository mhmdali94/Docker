# GoToSocial — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [GoToSocial](https://gotosocial.org) — a lightweight ActivityPub (Mastodon-compatible) social network server.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/social/gotosocial/gotosocial-ubuntu.sh
chmod +x gotosocial-ubuntu.sh
sudo bash gotosocial-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Accounts | Created via `docker exec -it gotosocial /gotosocial/gotosocial admin account create ...` |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8165` | Web + API |

## 💻 Connect

```bash
http://SERVER_IP:8165
```

## 📝 Notes

- For federation you need a real domain with HTTPS in front (Caddy/NPM scripts in this repo work well).

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
