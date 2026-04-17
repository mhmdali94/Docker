# Authentik — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Authentik](https://goauthentik.io/) — an open-source identity provider supporting SSO, OAuth2, SAML, LDAP, and multi-factor authentication.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/security/authentik/authentik-ubuntu.sh
chmod +x authentik-ubuntu.sh
sudo bash authentik-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Admin account | Created via initial setup wizard |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `9010` | Authentik Web UI (HTTP) |
| `9443` | Authentik Web UI (HTTPS) |

## 💻 Connect

```bash
# Initial setup wizard
http://SERVER_IP:9010/if/flow/initial-setup/

# Admin interface
http://SERVER_IP:9010/if/admin/
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
