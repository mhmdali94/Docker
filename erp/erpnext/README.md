# ERPNext

100% open-source ERP built on the Frappe framework. Covers Accounting, HR, Manufacturing, CRM, Projects, Buying, Selling, Stock, and more.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/erp/erpnext/erpnext-ubuntu.sh
chmod +x erpnext-ubuntu.sh
sudo bash erpnext-ubuntu.sh
```

## What It Installs

- **ERPNext v15** — ERP application (Frappe framework)
- **MariaDB 10.6** — database backend
- **Redis** — caching and queue

## Credentials

| Field | Value |
| --- | --- |
| URL | http://\<server-ip\>:8119 |
| Username | administrator |
| Password | Generated at install |

## Ports

| Port | Service |
| --- | --- |
| 8119 | ERPNext Web UI |

## Connect

Open `http://<server-ip>:8119` and log in with `administrator` and the password shown at install. Complete the setup wizard to configure your company, currency, and modules.

## Notes

- First startup takes 5-10 minutes for site initialization and migrations
- The installer runs `bench new-site` and `bench install-app erpnext` automatically
- For production use, see the official frappe_docker repository for a hardened multi-worker setup
