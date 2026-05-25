# Seafile

Self-hosted Dropbox alternative with file versioning, encryption, and team collaboration. Desktop and mobile sync clients available.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/files/seafile/seafile-ubuntu.sh
chmod +x seafile-ubuntu.sh
sudo bash seafile-ubuntu.sh
```

## What It Installs

- **Seafile** — File sync and share server
- **MariaDB** — Database
- **Memcached** — Cache layer

## Ports

| Port | Service |
| --- | --- |
| 8090 | Seafile web interface |

## Access

| | URL |
| --- | --- |
| Seafile | `http://<server-ip>:8090` |

## Default Credentials

| Field | Value |
| --- | --- |
| Email | `admin@seafile.local` |
| Password | Generated during install (shown at end) |

## Sync Clients

Download desktop/mobile clients from [seafile.com/download](https://www.seafile.com/en/download/):

| Platform | Client |
| --- | --- |
| Windows / macOS / Linux | Seafile Drive / Seafile Client |
| Android / iOS | Seafile mobile app |

## Notes

- Files are stored in `./data/` and versioned automatically
- File versioning keeps deleted/modified files for 30 days by default
- Supports server-side encryption per library
- Initialization takes ~60 seconds on first start
