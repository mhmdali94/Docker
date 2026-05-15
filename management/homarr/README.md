# Homarr

Modern self-hosted dashboard with service integrations — shows live stats from Sonarr, Radarr, Jellyfin, and more.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/management/homarr/homarr-ubuntu.sh
chmod +x homarr-ubuntu.sh
sudo bash homarr-ubuntu.sh
```

## What It Installs

- **Homarr** — service dashboard with integrations

## Credentials

| Field | Value |
| --- | --- |
| URL | http://\<server-ip\>:7575 |
| Auth | None (demo mode) |

## Ports

| Port | Service |
| --- | --- |
| 7575 | Homarr Web UI |

## Connect

Open `http://<server-ip>:7575`. Add service tiles via the edit mode (pencil icon). Homarr reads the Docker socket to auto-discover running containers.
