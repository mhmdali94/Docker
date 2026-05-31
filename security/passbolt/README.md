# Passbolt CE — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Passbolt is an open-source team password manager built for collaboration, with end-to-end encryption using OpenPGP and a browser extension for autofill.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Passbolt?

Passbolt CE is a security-focused password manager designed for teams. Passwords are encrypted with OpenPGP end-to-end, meaning the server never sees plaintext credentials. It supports shared folders, role-based access, audit logs, and a browser extension for autofill. It is the open-source alternative to 1Password Teams or Bitwarden Business.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/security/passbolt/passbolt-ubuntu.sh
chmod +x passbolt-ubuntu.sh
sudo bash passbolt-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure database credentials
- Starts Passbolt and MariaDB
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `https://SERVER_IP:8444` (HTTPS, accept SSL warning) |
| **Username** | Created via admin registration command |
| **Password** | Created via admin registration command |

> Replace `SERVER_IP` with your server's actual IP address.

**Register the first admin account** by running:

```bash
docker exec passbolt su -m www-data -c \
  '/usr/share/php/passbolt/bin/cake passbolt register_user \
  -u admin@example.com -f Admin -l User -r admin'
```

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8444` | TCP | HTTPS Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/passbolt/` | All service data and configuration |
| `/root/docker/passbolt/gpg/` | GPG server keys |
| `/root/docker/passbolt/jwt/` | JWT authentication keys |
| `/root/docker/passbolt/mysql/` | MariaDB database |

---

## Management

```bash
# Follow logs
docker logs -f passbolt

# Stop
cd /root/docker/passbolt && docker compose down

# Start
cd /root/docker/passbolt && docker compose up -d

# Update to latest image
cd /root/docker/passbolt && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8444/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
