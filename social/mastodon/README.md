# Mastodon

Open-source, decentralized social network. Twitter/X alternative that federates with thousands of other instances via ActivityPub. Run your own instance for your community.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/social/mastodon/mastodon-ubuntu.sh
chmod +x mastodon-ubuntu.sh
sudo bash mastodon-ubuntu.sh
```

## What It Installs

- **Mastodon Web** — Main web interface
- **Mastodon Sidekiq** — Background job worker
- **Mastodon Streaming** — Real-time WebSocket server
- **PostgreSQL 15** — Database
- **Redis 7** — Cache and queues

## Ports

| Port | Service |
| --- | --- |
| 3005 | Mastodon web UI |
| 4000 | Streaming API (WebSocket) |

## Requirements

- A **real domain name** — Mastodon requires a domain for federation
- DNS A record pointing to your server's IP

## Default Credentials

Admin account created as `admin@<your-domain>`. Reset the password:
```bash
docker exec mastodon-web bash -c \
  "RAILS_ENV=production bundle exec tootctl accounts modify admin --reset-password"
```

## Notes

- Media files stored in `./public/system/`
- PostgreSQL in `./postgres/`, Redis in `./redis/`
- Put behind Caddy or Nginx with HTTPS for production use
- Federation with other Mastodon/Fediverse servers works automatically once DNS is set
- Supports mobile apps: Tusky (Android), Ivory, Mona (iOS)
