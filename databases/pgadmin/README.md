# pgAdmin

The most popular open-source web GUI for PostgreSQL. Browse databases, run queries, manage users, view explain plans, and monitor server activity — all from a browser.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/databases/pgadmin/pgadmin-ubuntu.sh
chmod +x pgadmin-ubuntu.sh
sudo bash pgadmin-ubuntu.sh
```

## What It Installs

- **pgAdmin 4** — PostgreSQL web management interface

## Ports

| Port | Service |
| --- | --- |
| 5050 | pgAdmin web UI |

## Access

| | URL |
| --- | --- |
| Web UI | `http://<server-ip>:5050` |

## Default Credentials

| Field | Value |
| --- | --- |
| Email | Set during install |
| Password | Generated during install (shown at end) |

## Connecting to PostgreSQL

1. Open pgAdmin and log in
2. Right-click **Servers → Register → Server**
3. Enter your PostgreSQL host, port (5432), username, and password

## Notes

- Data (saved connections, preferences) stored in `./data/`
- Runs in desktop mode — no login required on the same machine
- Supports multiple PostgreSQL servers from one UI
