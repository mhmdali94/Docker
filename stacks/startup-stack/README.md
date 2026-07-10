# Startup Stack — One-Command Stack

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

The small-business essentials in one shot: **Plausible** (privacy analytics), **Listmonk** (newsletters), **Uptime Kuma** (uptime monitoring).

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/stacks/startup-stack/startup-stack-ubuntu.sh
chmod +x startup-stack-ubuntu.sh
sudo bash startup-stack-ubuntu.sh
```

## 📦 What's inside

- **Plausible CE** — GDPR-friendly web analytics
- **Listmonk** — newsletter & mailing lists (admin auto-created)
- **Uptime Kuma** — uptime monitoring & status

## 🌐 Ports

| Port | Service |
|------|---------|
| `8100` | Plausible |
| `9000` | Listmonk |
| `3001` | Uptime Kuma |

## 🔗 Wiring

Each app is initialized (Listmonk DB installed + admin created automatically). Pair with `support/chatwoot` and `tools/calcom` from this repo to complete the toolbelt.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
