# EspoCRM

Modern open-source CRM with a clean UI. Covers leads, contacts, accounts, opportunities, activities, email client, calendar, and workflow automation.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/crm/espocrm/espocrm-ubuntu.sh
chmod +x espocrm-ubuntu.sh
sudo bash espocrm-ubuntu.sh
```

## What It Installs

- **EspoCRM** — CRM application
- **EspoCRM Daemon** — background job processor
- **MariaDB 10.6** — database backend

## Credentials

| Field | Value |
| --- | --- |
| URL | http://\<server-ip\>:8130 |
| Username | admin |
| Password | Generated at install |

## Ports

| Port | Service |
| --- | --- |
| 8130 | EspoCRM Web UI |

## Connect

Open `http://<server-ip>:8130` and log in with `admin` and the password shown at install. Configure your organization, import leads/contacts, and set up workflow automations from the Administration panel.

## Notes

- A separate daemon container handles scheduled jobs, emails, and background workflows
- EspoCRM supports Arabic (RTL) and 30+ other languages
- Extension marketplace available at EspoCRM Store for email marketing, VoIP, and portal features
