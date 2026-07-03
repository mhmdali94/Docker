# Docker Registry — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Docker Registry](https://distribution.github.io/distribution/) — a private Docker image registry with a clean web UI.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/registry/registry-ubuntu.sh
chmod +x registry-ubuntu.sh
sudo bash registry-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `5011` | Registry API |
| `8213` | Web UI |

## 💻 Connect

```bash
docker login SERVER_IP:5011
```

## 📝 Notes

- For HTTP access add `{\"insecure-registries\": [\"SERVER_IP:5011\"]}` to client /etc/docker/daemon.json.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
