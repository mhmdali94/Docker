# Dokploy — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Dokploy](https://dokploy.com) — an open-source PaaS for deploying apps and databases (Vercel/Heroku/Netlify alternative).

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/dokploy/dokploy-ubuntu.sh
chmod +x dokploy-ubuntu.sh
sudo bash dokploy-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Admin | Created on first visit |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `3000` | Dokploy UI |
| `80` / `443` | Traefik (deployed apps) |

## 💻 Connect

```bash
http://SERVER_IP:3000
```

## 📝 Notes

- Uses the official Dokploy installer, which initializes **Docker Swarm** on this host.
- Ports 80, 443 and 3000 must be free before installing.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
