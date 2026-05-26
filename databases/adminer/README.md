# Adminer

Single-file universal database GUI. Connect to MySQL, PostgreSQL, SQLite, MongoDB, and more — all from one lightweight web interface. No installation, no config, just run.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/databases/adminer/adminer-ubuntu.sh
chmod +x adminer-ubuntu.sh
sudo bash adminer-ubuntu.sh
```

## What It Installs

- **Adminer** — Universal database management UI

## Ports

| Port | Service |
| --- | --- |
| 8086 | Adminer web UI |

## Access

| | URL |
| --- | --- |
| Web UI | `http://<server-ip>:8086` |

## Supported Databases

| Database | Notes |
| --- | --- |
| MySQL / MariaDB | Full support |
| PostgreSQL | Full support |
| SQLite | File path as server |
| MongoDB | With plugin |
| Elasticsearch | With plugin |

## Notes

- No credentials stored — enter your DB connection details on the login page
- Dracula dark theme enabled by default
- Much lighter than phpMyAdmin or pgAdmin
- Can connect to any database accessible from the container's network
