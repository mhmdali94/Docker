# Infisical — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Infisical](https://infisical.com/) — open-source secrets management platform. Centralize environment variables and API keys with fine-grained access control, audit logs, and SDK integrations.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/infisical/infisical-ubuntu.sh
chmod +x infisical-ubuntu.sh
sudo bash infisical-ubuntu.sh
```

## 🔑 Credentials

No default credentials — create your admin account on first visit.

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8090` | Infisical Web UI & API |

## 💻 Connect

```bash
# Web UI
http://SERVER_IP:8090

# CLI usage (after login)
infisical login --domain http://SERVER_IP:8090
infisical secrets
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
