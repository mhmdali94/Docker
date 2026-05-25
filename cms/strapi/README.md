# Strapi

Open-source headless CMS. Build your content structure visually, then consume it via REST or GraphQL API. Works with any frontend framework.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/cms/strapi/strapi-ubuntu.sh
chmod +x strapi-ubuntu.sh
sudo bash strapi-ubuntu.sh
```

## What It Installs

- **Strapi** — Headless CMS
- **PostgreSQL 15** — Database

## Ports

| Port | Service |
| --- | --- |
| 1337 | Strapi (admin + API) |

## Access

| | URL |
| --- | --- |
| Admin | `http://<server-ip>:1337/admin` |
| REST API | `http://<server-ip>:1337/api` |
| GraphQL | `http://<server-ip>:1337/graphql` |

## Default Credentials

None — the first visit to `/admin` creates your admin account.

## Quick Start

1. Open the admin panel and create your admin account
2. Go to **Content-Type Builder** and define your data models
3. Add content in the **Content Manager**
4. Set API permissions in **Settings → Roles**
5. Fetch content via the API

```bash
# Example API request (after enabling public access)
curl http://<server-ip>:1337/api/articles
```

## Notes

- Uploaded media stored in `./uploads/`
- PostgreSQL data stored in `./postgres/`
- All secrets and API keys are auto-generated during install
- Supports REST + GraphQL, webhooks, and role-based access
