# Woodpecker CI — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Woodpecker CI](https://woodpecker-ci.org/) — a simple, yet powerful CI/CD engine with YAML pipeline definitions and Docker-native execution.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/woodpecker/woodpecker-ubuntu.sh
chmod +x woodpecker-ubuntu.sh
sudo bash woodpecker-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Login | Via OAuth (Gitea / GitHub / GitLab) |
| Agent Secret | Auto-generated (shown at install) |

> **Note:** You must configure an OAuth provider in `/root/docker/woodpecker/docker-compose.yml` before logging in.

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8093` | Woodpecker Web UI |
| `9003` | Agent gRPC (internal) |

## 💻 Connect

```bash
# Web UI
http://SERVER_IP:8093

# Edit OAuth config
nano /root/docker/woodpecker/docker-compose.yml
cd /root/docker/woodpecker && docker compose up -d
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
