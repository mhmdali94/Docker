# HashiCorp Vault — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

HashiCorp Vault is a secrets management platform for securely storing and controlling access to tokens, passwords, certificates, API keys, and other secrets.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is HashiCorp Vault?

Vault provides a unified interface to secrets with tight access control, detailed audit logging, and dynamic secret generation. It supports multiple secret backends (KV, database credentials, PKI, cloud IAM), authentication methods (tokens, LDAP, Kubernetes, etc.), and encryption as a service. It is the industry standard for secrets management.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/security/vault/vault-ubuntu.sh
chmod +x vault-ubuntu.sh
sudo bash vault-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Writes a file-based storage configuration
- Starts Vault, initializes it, and unseals it automatically
- Saves unseal keys and root token to `/root/docker/vault/vault-init.txt`

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:8200` |
| **Root Token** | Auto-generated during install (displayed in terminal and saved to `vault-init.txt`) |

> Replace `SERVER_IP` with your server's actual IP address.
> **Back up `/root/docker/vault/vault-init.txt` immediately — it contains your unseal keys and root token.**

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8200` | TCP | Web UI / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/vault/` | All service data and configuration |
| `/root/docker/vault/config/vault.hcl` | Vault configuration |
| `/root/docker/vault/data/` | Encrypted secret storage |
| `/root/docker/vault/vault-init.txt` | Unseal keys and root token (protect this file) |

---

## Management

```bash
# Follow logs
docker logs -f vault

# Stop
cd /root/docker/vault && docker compose down

# Start
cd /root/docker/vault && docker compose up -d

# Update to latest image
cd /root/docker/vault && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8200/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
