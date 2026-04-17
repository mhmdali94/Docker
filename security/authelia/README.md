# Authelia — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Authelia](https://www.authelia.com/) — an open-source SSO and 2FA authentication gateway designed to be used with reverse proxies.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/security/authelia/authelia-ubuntu.sh
chmod +x authelia-ubuntu.sh
sudo bash authelia-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `authelia` |
| Password | `changeme2024` (**change immediately**) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `9091` | Authelia Web UI |

## 💻 Connect

```bash
# Web UI
http://SERVER_IP:9091

# Update users
nano /root/docker/authelia/config/users_database.yml

# Integrate with Nginx Proxy Manager or Traefik
# as a forward-auth middleware.
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
