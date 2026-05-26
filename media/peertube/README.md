# PeerTube

Self-hosted video platform that federates with the Fediverse. Upload, host, and stream videos — YouTube alternative with no ads, no algorithms, and no data collection.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/media/peertube/peertube-ubuntu.sh
chmod +x peertube-ubuntu.sh
sudo bash peertube-ubuntu.sh
```

## What It Installs

- **PeerTube** — Video hosting platform
- **PostgreSQL 15** — Database
- **Redis 7** — Cache and job queue

## Ports

| Port | Service |
| --- | --- |
| 9300 | PeerTube web UI + API |

## Requirements

- A **real domain name** for federation
- Sufficient disk space — videos can be large

## Default Credentials

Admin password is auto-generated on first start:
```bash
docker logs peertube 2>&1 | grep -i password
```

## Notes

- Videos and thumbnails stored in `./data/`
- PostgreSQL in `./postgres/`, Redis in `./redis/`
- Federates with other PeerTube instances and Mastodon (follow channels from Mastodon)
- Uses WebTorrent for P2P video delivery — reduces server bandwidth
- Supports live streaming, chapters, subtitles, playlists, and channels
- Recommended: put behind Caddy/Nginx with HTTPS for production
