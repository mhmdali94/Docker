# Dockge

Compose-first Docker stack manager — manage your docker-compose stacks with a clean web UI.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/management/dockge/dockge-ubuntu.sh
chmod +x dockge-ubuntu.sh
sudo bash dockge-ubuntu.sh
```

## What It Installs

- **Dockge** — Docker Compose stack manager

## Credentials

| Field | Value |
| --- | --- |
| URL | http://\<server-ip\>:5521 |
| Setup | Register on first visit |

## Ports

| Port | Service |
| --- | --- |
| 5521 | Dockge Web UI |

## Connect

Register your admin account at `http://<server-ip>:5521`. Stacks are managed from `/opt/stacks` on the host — copy your existing compose directories there to import them.
