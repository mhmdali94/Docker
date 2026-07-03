# Zitadel — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Zitadel](https://zitadel.com) — a modern identity and access management platform (OIDC, SAML, passkeys).

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/security/zitadel/zitadel-ubuntu.sh
chmod +x zitadel-ubuntu.sh
sudo bash zitadel-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `zitadel-admin@zitadel.SERVER_IP` |
| Password | `Password1!` (forced change on first login) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8171` | Console + APIs |

## 💻 Connect

```bash
http://SERVER_IP:8171/ui/console
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
