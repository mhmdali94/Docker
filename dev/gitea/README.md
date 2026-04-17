# Gitea — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Gitea](https://gitea.io/) — a lightweight, self-hosted Git service with issues, pull requests, CI/CD hooks, and a web UI.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/gitea/gitea-ubuntu.sh
chmod +x gitea-ubuntu.sh
sudo bash gitea-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Admin account | Created via setup wizard on first visit |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `3100` | Gitea Web UI |
| `2222` | Git SSH |

## 💻 Connect

```bash
# Web UI
http://SERVER_IP:3100

# Clone via SSH
git clone ssh://git@SERVER_IP:2222/username/repo.git

# Clone via HTTP
git clone http://SERVER_IP:3100/username/repo.git
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
