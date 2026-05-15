# Passbolt CE — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Passbolt Community Edition](https://www.passbolt.com/) — open-source password manager built for teams. Share credentials securely with GPG encryption, role-based access, and full audit logs.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/security/passbolt/passbolt-ubuntu.sh
chmod +x passbolt-ubuntu.sh
sudo bash passbolt-ubuntu.sh
```

## 🔑 Credentials

No default credentials — create the admin account via CLI after install (see below).

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8444` | Passbolt Web UI (HTTPS) |

## 💻 Connect

```bash
# Web UI (accepts self-signed certificate)
https://SERVER_IP:8444

# Create your first admin account
docker exec passbolt su -m www-data -c \
  '/usr/share/php/passbolt/bin/cake passbolt register_user \
  -u admin@example.com -f Admin -l User -r admin'
```

## ⚙️ Notes

- Passbolt uses HTTPS with a self-signed certificate by default — accept the browser warning
- The browser extension is required for full functionality: install from Chrome/Firefox extension stores
- For email notifications, configure SMTP environment variables and restart the container

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
