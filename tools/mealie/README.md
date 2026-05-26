# Mealie

Self-hosted recipe manager and meal planner. Import recipes from any URL, organize by tags, plan weekly meals, and auto-generate shopping lists.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/mealie/mealie-ubuntu.sh
chmod +x mealie-ubuntu.sh
sudo bash mealie-ubuntu.sh
```

## What It Installs

- **Mealie** — Recipe manager with built-in SQLite database

## Ports

| Port | Service |
| --- | --- |
| 9925 | Mealie web UI |

## Access

| | URL |
| --- | --- |
| Web UI | `http://<server-ip>:9925` |

## Default Credentials

| Field | Value |
| --- | --- |
| Email | `admin@mealie.local` |
| Password | `MyPassword` |

**Change the password immediately after first login.**

## Features

- Import recipes from 300+ websites by pasting a URL
- Meal planner with drag-and-drop week view
- Auto-generated shopping lists from planned meals
- Nutritional information (via OpenFoodFacts)
- Multi-user with household sharing
- Mobile-friendly PWA — works offline
- REST API for automation

## Notes

- Recipe data and images stored in `./data/`
- Uses SQLite by default — no separate database needed
- Mobile apps available via browser (add to home screen)
