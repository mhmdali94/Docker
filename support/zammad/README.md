# Zammad

Full-featured open-source helpdesk and ticketing system. Manage support requests from email, chat, phone, and social media in one place — self-hosted Zendesk alternative.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/support/zammad/zammad-ubuntu.sh
chmod +x zammad-ubuntu.sh
sudo bash zammad-ubuntu.sh
```

## What It Installs

- **Zammad** — Helpdesk (web + websocket + scheduler)
- **PostgreSQL 15** — Database
- **Elasticsearch 8** — Full-text search
- **Redis 7** — Cache
- **Memcached** — Session cache
- **Nginx** — Reverse proxy

## Ports

| Port | Service |
| --- | --- |
| 3036 | Zammad web UI |

## Access

| | URL |
| --- | --- |
| Web UI | `http://<server-ip>:3036` |

## Default Credentials

None — a setup wizard runs on first visit.

## Features

- Unified inbox for email, chat, Twitter, Facebook, and phone
- Ticket assignment, escalation, and SLA management
- Knowledge base / FAQ for self-service
- Customer portal with ticket tracking
- Agent performance reports and dashboards
- Macro automation and triggers
- REST API for integrations

## Notes

- Storage (attachments) in `./storage/`
- PostgreSQL in `./postgres/`
- First startup takes 2–4 minutes while the database is initialized
- Requires 4 GB+ RAM for comfortable operation (Elasticsearch is heavy)
