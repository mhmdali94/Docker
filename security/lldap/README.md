# LLDAP — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [LLDAP](https://github.com/lldap/lldap) — a light LDAP server for user management — the perfect backend for Authelia, Authentik, Jellyfin and co.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/security/lldap/lldap-ubuntu.sh
chmod +x lldap-ubuntu.sh
sudo bash lldap-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `3890` | LDAP |
| `17170` | Web UI |

## 💻 Connect

```bash
http://SERVER_IP:17170
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
