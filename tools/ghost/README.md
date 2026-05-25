# Ghost

Professional open-source publishing platform. Modern CMS for blogs, newsletters, and membership sites with a clean editor and built-in SEO.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/ghost/ghost-ubuntu.sh
chmod +x ghost-ubuntu.sh
sudo bash ghost-ubuntu.sh
```

## What It Installs

- **Ghost** — Publishing platform (v5)
- **MySQL 8.0** — Database

## Ports

| Port | Service |
| --- | --- |
| 2368 | Ghost blog + admin panel |

## Access

| | URL |
| --- | --- |
| Blog | `http://<server-ip>:2368` |
| Admin | `http://<server-ip>:2368/ghost` |

## Default Credentials

None — the first visit to `/ghost` creates your admin account.

## Notes

- Content (images, themes, uploads) stored in `./content/`
- MySQL data stored in `./mysql/`
- First startup takes ~60 seconds while MySQL initializes
- Supports custom themes, newsletters, memberships, and Stripe payments
- Set a real domain as the URL for proper link generation and email delivery
