# Harbor — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Harbor](https://goharbor.io/) — an open-source container registry with vulnerability scanning, RBAC, replication, and a web UI.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/harbor/harbor-ubuntu.sh
chmod +x harbor-ubuntu.sh
sudo bash harbor-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `5080` | Harbor Web UI |

## 💻 Connect

```bash
# Web UI
http://SERVER_IP:5080

# Docker login
docker login SERVER_IP:5080

# Push an image
docker tag myimage SERVER_IP:5080/library/myimage:latest
docker push SERVER_IP:5080/library/myimage:latest
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
