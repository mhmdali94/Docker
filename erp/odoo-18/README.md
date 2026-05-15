# Odoo 18

Full-featured open-source ERP with modules for CRM, Sales, Inventory, Accounting, HR, Manufacturing, Point of Sale, E-commerce, and more.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/erp/odoo-18/odoo18-ubuntu.sh
chmod +x odoo18-ubuntu.sh
sudo bash odoo18-ubuntu.sh
```

## What It Installs

- **Odoo 18** — ERP application server
- **PostgreSQL 15** — database backend

## Credentials

| Field | Value |
| --- | --- |
| URL | http://\<server-ip\>:8018 |
| DB Manager URL | http://\<server-ip\>:8018/web/database/manager |
| Master Password | Generated at install |

## Ports

| Port | Service |
| --- | --- |
| 8018 | Odoo Web UI |

## Connect

Open `http://<server-ip>:8018/web/database/manager` to create your first database. Use the master password shown at install time. Once the database is created, log in with the admin credentials you set during database creation.

## Notes

- Odoo downloads additional assets on first launch — allow 2-3 minutes
- Extra community modules can be placed in `./addons` (mounted at `/mnt/extra-addons`)
- For Odoo 16 or 17, separate scripts are available in `erp/odoo-16/` and `erp/odoo-17/`
