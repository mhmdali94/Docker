# Restic REST Server

Lightweight HTTP backend for Restic backups — host your own Restic repository server.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/backup/restic/restic-ubuntu.sh
chmod +x restic-ubuntu.sh
sudo bash restic-ubuntu.sh
```

## What It Installs

- **Restic REST Server** — Restic repository HTTP backend

## Credentials

| Field | Value |
| --- | --- |
| URL | http://\<server-ip\>:8400 |
| Auth | None (demo mode — `--no-auth`) |

## Ports

| Port | Service |
| --- | --- |
| 8400 | Restic REST Server |

## Connect

Point your Restic client at this server:

```bash
restic -r rest:http://<server-ip>:8400/<repo-name> init
restic -r rest:http://<server-ip>:8400/<repo-name> backup /path/to/data
```

For production, remove `--no-auth` and configure `htpasswd` authentication.
