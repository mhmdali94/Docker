# HashiCorp Vault

Secrets management platform. Securely store and access API keys, passwords, certificates, and encryption keys with audit logging and fine-grained access control.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/security/vault/vault-ubuntu.sh
chmod +x vault-ubuntu.sh
sudo bash vault-ubuntu.sh
```

## What It Installs

- **HashiCorp Vault** — Secrets management server

## Ports

| Port | Service |
| --- | --- |
| 8200 | Vault UI + API |

## Access

| | URL |
| --- | --- |
| Web UI | `http://<server-ip>:8200/ui` |
| API | `http://<server-ip>:8200/v1/` |

## Initialization

The script initializes Vault automatically and saves the unseal keys and root token to `/root/docker/vault/vault-init.txt`.

**Back up this file immediately** — without the unseal keys, you cannot access Vault after a restart.

After every restart, Vault must be unsealed:
```bash
docker exec vault vault operator unseal <Unseal-Key-1>
docker exec vault vault operator unseal <Unseal-Key-2>
```

## Using Vault

```bash
# Set token for CLI
export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=<root-token>

# Store a secret
vault kv put secret/myapp db_password=mypassword

# Read a secret
vault kv get secret/myapp
```

## Notes

- Data stored in `./data/` (file storage backend)
- TLS disabled — use a reverse proxy with HTTPS for production
- For production: use HA storage backends (Consul, Raft, etc.)
- Supports dynamic secrets, PKI, SSH, and more secret engines
