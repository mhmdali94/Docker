# Headplane — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Headplane](https://github.com/tale/headplane) — a feature-rich web UI for your Headscale (self-hosted Tailscale) server.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/vpn/headplane/headplane-ubuntu.sh
chmod +x headplane-ubuntu.sh
sudo bash headplane-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `3054` | Web UI |

## 💻 Connect

```bash
http://SERVER_IP:3054/admin
```

## 📝 Notes

- Install `vpn/headscale` first; create an API key with `docker exec headscale headscale apikeys create`.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
