# GlitchTip

Sentry-compatible open-source error tracking — collects exceptions, performance metrics, and uptime checks.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/glitchtip/glitchtip-ubuntu.sh
chmod +x glitchtip-ubuntu.sh
sudo bash glitchtip-ubuntu.sh
```

## What It Installs

- **GlitchTip** — error tracking server + background worker
- **PostgreSQL** — primary database
- **Redis** — task queue

## Credentials

| Field | Value |
| --- | --- |
| URL | http://\<server-ip\>:8093 |
| Setup | Register on first visit |

## Ports

| Port | Service |
| --- | --- |
| 8093 | GlitchTip Web UI |

## Connect

Register your first account at `http://<server-ip>:8093`. The Sentry DSN format is fully compatible — use the `GLITCHTIP_HOST` in your SDK configuration.
