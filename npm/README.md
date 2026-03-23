# Nginx Proxy Manager (NPM) — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Nginx Proxy Manager](https://nginxproxymanager.com/) — a powerful reverse proxy with a web UI and built-in Let's Encrypt SSL support.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🚀 What the Script Does

1. **OS Check** — Verifies Ubuntu 22.04 or 24.04
2. **Docker Check** — Installs Docker if missing
3. **Docker Compose V2 Check** — Installs if missing
4. **Cleanup** — Removes any existing NPM containers and directory
5. **Auto-generates DB credentials** — Secure random passwords
6. **Generates `config.json`** — DB connection config for NPM
7. **Generates `docker-compose.yml`** — Ready to run stack
8. **Starts Containers** — `docker compose up -d`
9. **Shows login info** — Admin URL and DB credentials

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/npm/npm-ubuntu.sh
chmod +x npm-ubuntu.sh
sudo bash npm-ubuntu.sh
```

---

## 🔑 Default Login Credentials

| Field | Value |
|-------|-------|
| **Email** | `admin@example.com` |
| **Password** | `changeme` |

> ⚠️ Change these immediately after first login!

---

## 🌐 Ports Used

| Port | Purpose |
|------|---------|
| `80` | HTTP traffic |
| `443` | HTTPS traffic |
| `81` | Admin web UI |

---

## 📁 Files Location

```
/root/docker/npm/
├── docker-compose.yml
├── config.json
├── data/
└── letsencrypt/
```

---

**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
