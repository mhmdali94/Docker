# Concourse CI — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Concourse CI](https://concourse-ci.org) — the pipeline-native continuous integration system.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/concourse/concourse-ubuntu.sh
chmod +x concourse-ubuntu.sh
sudo bash concourse-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8244` | Web UI + API |

## 💻 Connect

```bash
fly -t demo login -c http://SERVER_IP:8244
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
