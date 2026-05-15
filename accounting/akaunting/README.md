# Akaunting

Free and open-source accounting software. Covers invoicing, expenses, bank reconciliation, tax reports, and multi-currency transactions.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/accounting/akaunting/akaunting-ubuntu.sh
chmod +x akaunting-ubuntu.sh
sudo bash akaunting-ubuntu.sh
```

## What It Installs

- **Akaunting** — accounting and invoicing application
- **MySQL 8** — database backend

## Credentials

| Field | Value |
| --- | --- |
| URL | http://\<server-ip\>:8127 |
| Email | admin@example.com |
| Password | Generated at install |

## Ports

| Port | Service |
| --- | --- |
| 8127 | Akaunting Web UI |

## Connect

Open `http://<server-ip>:8127` and log in with `admin@example.com` and the password shown at install. Complete the company setup wizard to configure your currency, tax settings, and chart of accounts.

## Notes

- First startup takes 2-3 minutes while Akaunting seeds the database
- Supports 60+ languages including Arabic (RTL)
- Free marketplace apps for payroll, inventory, and advanced reports are available
