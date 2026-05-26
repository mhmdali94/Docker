# Snipe-IT

Open-source IT asset management. Track laptops, servers, licenses, accessories, and consumables — know what you have, where it is, and who has it.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/snipeit/snipeit-ubuntu.sh
chmod +x snipeit-ubuntu.sh
sudo bash snipeit-ubuntu.sh
```

## What It Installs

- **Snipe-IT** — IT asset management
- **MySQL 8.0** — Database

## Ports

| Port | Service |
| --- | --- |
| 8002 | Snipe-IT web UI |

## Access

| | URL |
| --- | --- |
| Web UI | `http://<server-ip>:8002` |

## Default Credentials

None — a setup wizard runs on first visit to create the admin account.

## Features

- Asset tracking with QR/barcode labels
- Check-in / check-out to users and locations
- Software license management and seat counting
- Accessory and consumable tracking
- Maintenance scheduling and history
- Email notifications for due dates and check-outs
- REST API for integrations
- LDAP/Active Directory support

## Notes

- Config and uploads stored in `./data/`
- MySQL data in `./mysql/`
- Import assets in bulk via CSV
- Depreciation tracking for hardware
