# Saleor

High-performance headless e-commerce platform built on GraphQL. API-first architecture — connect any storefront (Next.js, React, mobile) to a powerful commerce backend.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ecommerce/saleor/saleor-ubuntu.sh
chmod +x saleor-ubuntu.sh
sudo bash saleor-ubuntu.sh
```

## What It Installs

- **Saleor API** — GraphQL commerce backend
- **Saleor Dashboard** — React admin UI
- **PostgreSQL 15** — Database
- **Redis 7** — Cache and task queue

## Ports

| Port | Service |
| --- | --- |
| 8010 | GraphQL API |
| 9001 | Admin Dashboard |

## Access

| | URL |
| --- | --- |
| GraphQL API | `http://<server-ip>:8010/graphql/` |
| Dashboard | `http://<server-ip>:9001` |
| GraphQL Playground | `http://<server-ip>:8010/graphql/` |

## Default Credentials

| Field | Value |
| --- | --- |
| Email | `admin@saleor.local` |
| Password | Set on first dashboard login |

## Notes

- First startup takes ~2 minutes while database migrations run
- Media files stored in `./media/`
- PostgreSQL data in `./postgres/`, Redis in `./redis/`
- Build your storefront with [Saleor Storefront](https://github.com/saleor/storefront) (Next.js)
- Supports multi-channel, multi-currency, and multi-warehouse
- Webhooks and apps marketplace for extensions
