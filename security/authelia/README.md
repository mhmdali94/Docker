# Authelia — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Authelia is a self-hosted SSO and two-factor authentication gateway that protects access to other web applications via Nginx or Traefik middleware.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Authelia?

Authelia acts as an authentication middleware in front of your reverse proxy. When a user accesses a protected service, they are redirected to Authelia to log in and complete two-factor authentication (TOTP). Once authenticated, they are forwarded to the target service. It supports LDAP, file-based users, and multiple 2FA methods.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/security/authelia/authelia-ubuntu.sh
chmod +x authelia-ubuntu.sh
sudo bash authelia-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Detects your server IP and creates a nip.io domain
- Generates a self-signed TLS certificate
- Starts the Authelia and Redis containers
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `https://SERVER_IP.nip.io:9091` (HTTPS, self-signed cert — accept browser warning) |
| **Username** | `authelia` |
| **Password** | `changeme2024` |

> Replace `SERVER_IP` with your server's actual IP address.

> **After first login:** Register your TOTP device by running:
> ```bash
> cat /root/docker/authelia/config/notification.txt
> ```
> Open the link shown in that file to complete TOTP device registration.

> **Important:** Authelia is an authentication middleware — pair it with Nginx or Traefik to protect other services.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `9091` | TCP | HTTPS Web UI / Auth endpoint |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/authelia/` | All service data and configuration |
| `/root/docker/authelia/config/configuration.yml` | Main configuration |
| `/root/docker/authelia/config/users_database.yml` | User accounts |
| `/root/docker/authelia/config/notification.txt` | TOTP registration links |

---

## Management

```bash
# Follow logs
docker logs -f authelia

# Stop
cd /root/docker/authelia && docker compose down

# Start
cd /root/docker/authelia && docker compose up -d

# Update to latest image
cd /root/docker/authelia && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 9091/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
