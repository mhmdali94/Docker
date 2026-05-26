# Formbricks

Open-source survey and form builder. Create in-app surveys, customer satisfaction forms, NPS surveys, and product feedback widgets — self-hosted Typeform alternative.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/formbricks/formbricks-ubuntu.sh
chmod +x formbricks-ubuntu.sh
sudo bash formbricks-ubuntu.sh
```

## What It Installs

- **Formbricks** — Survey and form platform
- **PostgreSQL 15** — Database

## Ports

| Port | Service |
| --- | --- |
| 3001 | Formbricks web UI |

## Access

| | URL |
| --- | --- |
| Web UI | `http://<server-ip>:3001` |

## Default Credentials

None — create your account on first visit.

## Features

- Drag-and-drop survey builder
- In-app widgets (embed surveys inside your product)
- Link surveys (shareable public URL)
- NPS, CSAT, CES, and custom survey types
- Response analytics and exports
- Webhooks and REST API for integrations
- SDKs for React, Vue, and vanilla JS

## Notes

- Uploads stored in `./uploads/`
- PostgreSQL data in `./postgres/`
- Embed surveys into your web app with one script tag
