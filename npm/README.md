# Nginx Proxy Manager (NPM) — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

This folder contains a Docker Compose setup for [Nginx Proxy Manager](https://nginxproxymanager.com/), a simple and powerful reverse proxy with a web UI.

**Made by:** [prismatechwork.com](https://prismatechwork.com)

---

## 🚀 What is Nginx Proxy Manager?

Nginx Proxy Manager lets you manage Nginx proxy hosts with a beautiful web interface and includes built-in support for free SSL certificates via Let's Encrypt.

---

## 📋 Prerequisites

| Requirement | Details |
|---|---|
| **OS** | Ubuntu 22.04 or 24.04 |
| **Permissions** | Root / sudo access |
| **Ports** | 80, 443, 81 must be open |

---

## 🛠 Usage

> *(Setup script coming soon)*

Manual setup:

**1. Navigate to this directory**
```bash
cd npm/
```

**2. Start the stack**
```bash
docker compose up -d
```

**3. Open the admin panel**
```
http://<your-server-ip>:81
```

Default credentials:
- **Email:** `admin@example.com`
- **Password:** `changeme`

> Change these immediately after first login!

---

## 🌐 Ports Used

| Port | Purpose |
|------|---------|
| `80` | HTTP traffic |
| `443` | HTTPS traffic |
| `81` | Admin web UI |

---

## ⚠️ Disclaimer

This setup is provided **strictly for demo and testing purposes**.
It is **not hardened for production environments**.

---

**Made by [prismatechwork.com](https://prismatechwork.com)**
