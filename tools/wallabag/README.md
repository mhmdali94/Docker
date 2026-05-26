# Wallabag

Self-hosted read-it-later app. Save articles from the web and read them later — clean, ad-free, offline. The open-source alternative to Pocket and Instapaper.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/wallabag/wallabag-ubuntu.sh
chmod +x wallabag-ubuntu.sh
sudo bash wallabag-ubuntu.sh
```

## What It Installs

- **Wallabag** — Read-it-later application
- **PostgreSQL 15** — Database
- **Redis 7** — Cache

## Ports

| Port | Service |
| --- | --- |
| 8095 | Wallabag web UI |

## Access

| | URL |
| --- | --- |
| Web UI | `http://<server-ip>:8095` |

## Default Credentials

| Field | Value |
| --- | --- |
| Username | `wallabag` |
| Password | `wallabag` |

**Change the password immediately after first login.**

## Browser Extension

Install the Wallabag browser extension to save pages with one click:
- [Chrome/Firefox extension](https://github.com/wallabag/wallabagger)

## Mobile Apps

- Android: Available on F-Droid and Play Store
- iOS: Available on App Store

## Notes

- Saved article images stored in `./images/`
- Full-text search across all saved articles
- Export to ePub, PDF, CSV, or JSON
- RSS feeds for each tag or search
- Supports annotations and highlights
