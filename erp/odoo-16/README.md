# Odoo 16

Full-featured open-source ERP with modules for CRM, Sales, Inventory, Accounting, HR, Manufacturing, Point of Sale, E-commerce, and more.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/erp/odoo-16/odoo16-ubuntu.sh
chmod +x odoo16-ubuntu.sh
sudo bash odoo16-ubuntu.sh
```

## What It Installs

- **Odoo 16** — ERP application server
- **PostgreSQL 15** — database backend

## Credentials

| Field | Value |
| --- | --- |
| URL | http://\<server-ip\>:8016 |
| DB Manager URL | http://\<server-ip\>:8016/web/database/manager |
| Master Password | Generated at install |

## Ports

| Port | Service |
| --- | --- |
| 8016 | Odoo Web UI |

## Connect

Open `http://<server-ip>:8016/web/database/manager` to create your first database. Use the master password shown at install time. Once the database is created, log in with the admin credentials you set during database creation.

## Notes

- Odoo downloads additional assets on first launch — allow 2-3 minutes
- Extra community modules can be placed in `./addons` (mounted at `/mnt/extra-addons`)
- For Odoo 17 or 18, separate scripts are available in `erp/odoo-17/` and `erp/odoo-18/`
