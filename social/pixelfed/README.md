# Pixelfed

Federated photo sharing platform. Instagram alternative that connects with Mastodon and the wider Fediverse via ActivityPub. Share photos with people on any compatible platform.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/social/pixelfed/pixelfed-ubuntu.sh
chmod +x pixelfed-ubuntu.sh
sudo bash pixelfed-ubuntu.sh
```

## What It Installs

- **Pixelfed** — Photo sharing platform
- **MySQL 8.0** — Database
- **Redis 7** — Cache and queues

## Ports

| Port | Service |
| --- | --- |
| 8085 | Pixelfed web UI |

## Requirements

- A **real domain name** for ActivityPub federation to work

## Default Credentials

None — register the first account through the web UI. Promote it to admin:
```bash
docker exec pixelfed php artisan user:admin <username>
```

## Notes

- Photos and media stored in `./storage/`
- MySQL data in `./mysql/`
- Federates with Mastodon — users on Mastodon can follow Pixelfed accounts
- Mobile apps: Pixelfed for iOS and Android
