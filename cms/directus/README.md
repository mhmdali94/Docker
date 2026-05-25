# Directus

Real-time headless CMS and data platform. Wraps any SQL database with an instant REST and GraphQL API, plus a beautiful no-code data studio.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/cms/directus/directus-ubuntu.sh
chmod +x directus-ubuntu.sh
sudo bash directus-ubuntu.sh
```

## What It Installs

- **Directus** — Headless CMS + data platform
- **PostgreSQL 15** — Database
- **Redis 7** — Cache

## Ports

| Port | Service |
| --- | --- |
| 8055 | Directus (app + API) |

## Access

| | URL |
| --- | --- |
| App | `http://<server-ip>:8055` |
| REST API | `http://<server-ip>:8055/items/<collection>` |
| GraphQL | `http://<server-ip>:8055/graphql` |

## Default Credentials

| Field | Value |
| --- | --- |
| Email | Set during install (default: `admin@directus.local`) |
| Password | Generated during install (shown at end) |

## Notes

- Uploaded files stored in `./uploads/`
- Custom extensions go in `./extensions/`
- PostgreSQL data in `./postgres/`, Redis in `./redis/`
- Works with existing databases — point it at your schema and get an instant API
- Supports real-time subscriptions, flows (automation), and webhooks
