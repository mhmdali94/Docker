# SuiteCRM

The world's most popular open-source CRM. A full fork of SugarCRM covering leads, opportunities, contacts, accounts, campaigns, cases, contracts, and reporting.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/crm/suitecrm/suitecrm-ubuntu.sh
chmod +x suitecrm-ubuntu.sh
sudo bash suitecrm-ubuntu.sh
```

## What It Installs

- **SuiteCRM** — CRM application
- **MariaDB** — database backend (via Bitnami)

## Credentials

| Field | Value |
| --- | --- |
| URL | http://\<server-ip\>:8129 |
| Username | admin |
| Password | Generated at install |

## Ports

| Port | Service |
| --- | --- |
| 8129 | SuiteCRM Web UI |

## Connect

Open `http://<server-ip>:8129` and log in with `admin` and the password shown at install. Complete the initial configuration wizard to set up your currency, timezone, and email settings.

## Notes

- First startup takes 3-5 minutes while SuiteCRM initializes and seeds the database
- Uses the Bitnami SuiteCRM image which includes automatic HTTPS and a pre-configured PHP environment
- Module Loader allows adding community extensions without modifying core files
