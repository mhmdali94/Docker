# Weblate

Web-based translation management platform. Let translators work on your app's strings directly in the browser, with Git integration, translation memory, and machine translation.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/weblate/weblate-ubuntu.sh
chmod +x weblate-ubuntu.sh
sudo bash weblate-ubuntu.sh
```

## What It Installs

- **Weblate** — Translation management platform
- **PostgreSQL 15** — Database
- **Redis 7** — Cache and task queue

## Ports

| Port | Service |
| --- | --- |
| 8003 | Weblate web UI |

## Access

| | URL |
| --- | --- |
| Web UI | `http://<server-ip>:8003` |

## Default Credentials

| Field | Value |
| --- | --- |
| Email | Set during install |
| Password | Generated during install (shown at end) |

## Quick Start

1. Log in as admin
2. Go to **Projects → Add project**
3. Create a **Component** linked to your Git repo
4. Invite translators by email or allow registration
5. Translators work on strings in the web UI — changes auto-commit to Git

## Features

- Git/GitHub/GitLab integration — auto-syncs translations
- Translation memory across projects
- Machine translation (DeepL, LibreTranslate, Google)
- Glossary management
- Quality checks and suggestions
- REST API for CI/CD integration

## Notes

- Project data stored in `./data/`
- PostgreSQL in `./postgres/`, Redis in `./redis/`
- Supports PO, XLIFF, JSON, Android XML, iOS Strings, and 60+ formats
