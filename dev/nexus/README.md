# Nexus Repository Manager — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Nexus Repository Manager 3](https://www.sonatype.com/products/sonatype-nexus-repository) — universal artifact repository. Store and serve Maven, npm, Docker images, PyPI, and 20+ other package formats from a single server.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/nexus/nexus-ubuntu.sh
chmod +x nexus-ubuntu.sh
sudo bash nexus-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | Auto-generated — shown at install, stored in `/root/docker/nexus/data/admin.password` |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8081` | Nexus Web UI |

## 💻 Connect

```bash
# Web UI
http://SERVER_IP:8081

# Retrieve initial admin password manually
cat /root/docker/nexus/data/admin.password
```

## ⚙️ Notes

- Nexus takes ~2 minutes to start on first boot
- Change the admin password immediately after first login
- Create repositories (npm, maven, docker, pypi) under Administration → Repositories

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
