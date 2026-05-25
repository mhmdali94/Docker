# Keycloak

Enterprise-grade identity and access management. SSO, OAuth2/OIDC provider, LDAP integration, and fine-grained authorization for your self-hosted apps.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/security/keycloak/keycloak-ubuntu.sh
chmod +x keycloak-ubuntu.sh
sudo bash keycloak-ubuntu.sh
```

## What It Installs

- **Keycloak** — Identity and access management server
- **PostgreSQL 15** — Database

## Ports

| Port | Service |
| --- | --- |
| 8180 | Keycloak (web + admin) |

## Access

| | URL |
| --- | --- |
| Home | `http://<server-ip>:8180` |
| Admin Console | `http://<server-ip>:8180/admin` |

## Default Credentials

| Field | Value |
| --- | --- |
| Username | Set during install (default: `admin`) |
| Password | Generated during install (shown at end) |

## Quick Start

1. Log into the Admin Console
2. Create a new **Realm** for your application
3. Create **Clients** (one per app you want to protect)
4. Create **Users** or connect an LDAP/Active Directory source
5. Configure your apps to use Keycloak as their OIDC provider

## Notes

- Running in `start-dev` mode — suitable for testing only
- For production: use `start` mode with HTTPS and a proper hostname
- Supports SAML 2.0, OAuth 2.0, OpenID Connect
- Can act as identity broker (Google, GitHub, Microsoft login)
- PostgreSQL data stored in `./postgres/`
