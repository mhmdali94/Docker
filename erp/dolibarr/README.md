# Dolibarr

Lightweight open-source ERP and CRM for small and medium businesses. Covers invoicing, accounting, stock, HR, projects, and e-commerce.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/erp/dolibarr/dolibarr-ubuntu.sh
chmod +x dolibarr-ubuntu.sh
sudo bash dolibarr-ubuntu.sh
```

## What It Installs

- **Dolibarr** — ERP/CRM application
- **MariaDB 10.6** — database backend

## Credentials

| Field | Value |
| --- | --- |
| URL | http://\<server-ip\>:8120 |
| Username | admin |
| Password | Generated at install |

## Ports

| Port | Service |
| --- | --- |
| 8120 | Dolibarr Web UI |

## Connect

Open `http://<server-ip>:8120` and log in with `admin` and the password shown at install. Enable modules from the Home → Setup → Modules page.

## Notes

- Dolibarr is one of the lightest ERP solutions — starts in under 30 seconds
- Supports Arabic language via built-in translation module
- Documents are stored in `./documents` (mounted at `/var/www/documents`)
