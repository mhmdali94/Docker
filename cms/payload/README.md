# Payload CMS

TypeScript-first headless CMS built for developers. Define your schema in code, get a full admin UI and REST/GraphQL API instantly — no proprietary config files.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/cms/payload/payload-ubuntu.sh
chmod +x payload-ubuntu.sh
sudo bash payload-ubuntu.sh
```

## What It Installs

- **Payload CMS** — Headless CMS
- **MongoDB 7** — Database

## Ports

| Port | Service |
| --- | --- |
| 3030 | Payload CMS (admin + API) |

## Access

| | URL |
| --- | --- |
| App | `http://<server-ip>:3030` |
| Admin | `http://<server-ip>:3030/admin` |
| REST API | `http://<server-ip>:3030/api` |
| GraphQL | `http://<server-ip>:3030/api/graphql` |

## Default Credentials

None — the first visit to `/admin` creates your admin account.

## Notes

- Media files stored in `./media/`
- MongoDB data stored in `./mongo/`
- Schema defined in code — customize by rebuilding the image with your config
- Supports access control, hooks, versioning, and localization
- Works great as a backend for Next.js, Nuxt, SvelteKit, etc.
