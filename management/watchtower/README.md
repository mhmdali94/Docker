# Watchtower

Automatic Docker container updater — polls for new image versions and restarts containers in place.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/management/watchtower/watchtower-ubuntu.sh
chmod +x watchtower-ubuntu.sh
sudo bash watchtower-ubuntu.sh
```

## What It Installs

- **Watchtower** — automated container update daemon

## Credentials

| Field | Value |
| --- | --- |
| Web UI | None — daemon only |

## Ports

| Port | Service |
| --- | --- |
| — | Daemon, no web port |

## Connect

Watchtower runs silently in the background. By default it checks for updates daily at 4:00 AM and removes old images after updating (`WATCHTOWER_CLEANUP=true`).

Check logs with: `docker logs watchtower`

To exclude a container from updates, add the label:
```yaml
labels:
  - "com.centurylinklabs.watchtower.enable=false"
```
