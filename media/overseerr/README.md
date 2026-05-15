# Overseerr

Media request management for Jellyfin/Plex — let users request movies and TV shows with automatic approval workflows.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/media/overseerr/overseerr-ubuntu.sh
chmod +x overseerr-ubuntu.sh
sudo bash overseerr-ubuntu.sh
```

## What It Installs

- **Overseerr** — media request and management platform

## Credentials

| Field | Value |
| --- | --- |
| URL | http://\<server-ip\>:5055 |
| Setup | Web wizard on first visit |

## Ports

| Port | Service |
| --- | --- |
| 5055 | Overseerr Web UI |

## Connect

Complete the setup wizard at `http://<server-ip>:5055`. Connect your Plex or Jellyfin server, then configure Radarr and Sonarr for automatic downloads. Users can sign in with their Plex account to request content.
