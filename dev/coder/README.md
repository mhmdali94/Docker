# Coder

Self-hosted cloud development environments — provision workspaces on Docker, Kubernetes, or cloud VMs.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/coder/coder-ubuntu.sh
chmod +x coder-ubuntu.sh
sudo bash coder-ubuntu.sh
```

## What It Installs

- **Coder** — dev environment platform
- **PostgreSQL** — primary database

## Credentials

| Field | Value |
| --- | --- |
| URL | http://\<server-ip\>:3020 |
| Username | admin |
| Password | Generated at install |

## Ports

| Port | Service |
| --- | --- |
| 3020 | Coder Web UI |

## Connect

Log in at `http://<server-ip>:3020` with the credentials shown at install. Create a Docker-based template to provision workspaces on the same host.
