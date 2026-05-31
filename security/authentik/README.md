# Authentik — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Authentik is a self-hosted identity provider (IdP) offering SSO, OAuth2/OIDC, SAML, LDAP, and a powerful policy engine for access control across your self-hosted applications.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Authentik?

Authentik is an enterprise-grade identity and access management platform that you can run entirely on your own infrastructure. It supports single sign-on (SSO), multi-factor authentication, user enrollment flows, OAuth2/OIDC and SAML providers, LDAP, and fine-grained policy-based access control. It is the open-source alternative to Okta or Azure AD.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/security/authentik/authentik-ubuntu.sh
chmod +x authentik-ubuntu.sh
sudo bash authentik-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure database and secret keys
- Starts the full Authentik stack (server, worker, PostgreSQL, Redis)
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI (HTTP)** | `http://SERVER_IP:9010/if/flow/initial-setup/` |
| **Web UI (HTTPS)** | `https://SERVER_IP:9443` |
| **Username** | Created during initial setup wizard |
| **Password** | Created during initial setup wizard |

> Replace `SERVER_IP` with your server's actual IP address. Navigate to the initial-setup URL to create your admin account.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `9010` | TCP | HTTP Web UI |
| `9443` | TCP | HTTPS Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/authentik/` | All service data and configuration |
| `/root/docker/authentik/pgdata/` | PostgreSQL database storage |
| `/root/docker/authentik/media/` | Uploaded media files |

---

## Management

```bash
# Follow logs
docker logs -f authentik-server

# Stop
cd /root/docker/authentik && docker compose down

# Start
cd /root/docker/authentik && docker compose up -d

# Update to latest image
cd /root/docker/authentik && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 9010/tcp and 9443/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
