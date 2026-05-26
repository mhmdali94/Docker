# Lemmy

Federated link aggregator and forum. Reddit alternative that federates with other Lemmy instances and the Fediverse. Run communities for your team, organization, or the public.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/social/lemmy/lemmy-ubuntu.sh
chmod +x lemmy-ubuntu.sh
sudo bash lemmy-ubuntu.sh
```

## What It Installs

- **Lemmy** — Backend server (Rust)
- **Lemmy UI** — Web frontend
- **pict-rs** — Image processing service
- **PostgreSQL 15** — Database

## Ports

| Port | Service |
| --- | --- |
| 8536 | Lemmy web UI |

## Requirements

- A **real domain name** for federation with other Lemmy instances

## Default Credentials

| Field | Value |
| --- | --- |
| Username | Set during install |
| Password | Generated during install (shown at end) |

## Notes

- Images stored in `./pictrs/`
- PostgreSQL data in `./postgres/`
- Federates with other Lemmy instances — users can subscribe to communities across instances
- Supports markdown, voting, communities, and moderation tools
- Mobile apps: Jerboa (Android), Mlem (iOS)
