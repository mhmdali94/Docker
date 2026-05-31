# Keycloak — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Keycloak is an enterprise-grade open-source identity and access management solution providing SSO, OAuth2/OIDC, SAML, and LDAP integration for your applications.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Keycloak?

Keycloak is the leading open-source identity provider used in enterprise environments. It provides single sign-on (SSO), multi-factor authentication, social login, fine-grained authorization, user federation via LDAP/Active Directory, and standards-based protocols (OAuth2, OpenID Connect, SAML 2.0). It is maintained by Red Hat.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/security/keycloak/keycloak-ubuntu.sh
chmod +x keycloak-ubuntu.sh
sudo bash keycloak-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates a secure admin password and database credentials
- Starts Keycloak and PostgreSQL
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:8180` |
| **Admin Console** | `http://SERVER_IP:8180/admin` |
| **Username** | `admin` (or custom value entered during install) |
| **Password** | Auto-generated during install (displayed in terminal) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8180` | TCP | Web UI / Admin Console |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/keycloak/` | All service data and configuration |
| `/root/docker/keycloak/postgres/` | PostgreSQL database storage |

---

## Management

```bash
# Follow logs
docker logs -f keycloak

# Stop
cd /root/docker/keycloak && docker compose down

# Start
cd /root/docker/keycloak && docker compose up -d

# Update to latest image
cd /root/docker/keycloak && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8180/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
