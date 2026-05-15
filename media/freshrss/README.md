# FreshRSS

Self-hosted RSS/Atom feed aggregator — read all your news sources in one place.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/media/freshrss/freshrss-ubuntu.sh
chmod +x freshrss-ubuntu.sh
sudo bash freshrss-ubuntu.sh
```

## What It Installs

- **FreshRSS** — multi-user RSS reader

## Credentials

| Field | Value |
| --- | --- |
| URL | http://\<server-ip\>:8097 |
| Setup | Web wizard on first visit |

## Ports

| Port | Service |
| --- | --- |
| 8097 | FreshRSS Web UI |

## Connect

Complete the setup wizard at `http://<server-ip>:8097`. FreshRSS also exposes a Google Reader–compatible API for mobile apps like FeedMe or Reeder.
