# Invoice Ninja

Open-source invoicing, billing, and payment platform. Covers quotes, invoices, recurring billing, expense tracking, time tracking, and client portal.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/accounting/invoice-ninja/invoice-ninja-ubuntu.sh
chmod +x invoice-ninja-ubuntu.sh
sudo bash invoice-ninja-ubuntu.sh
```

## What It Installs

- **Invoice Ninja v5** — invoicing and billing platform (Laravel)
- **MariaDB 10.6** — database backend

## Credentials

| Field | Value |
| --- | --- |
| URL | http://\<server-ip\>:8128 |
| Email | admin@example.com |
| Password | Generated at install |

## Ports

| Port | Service |
| --- | --- |
| 8128 | Invoice Ninja Web UI |

## Connect

Open `http://<server-ip>:8128` and log in with `admin@example.com` and the password shown at install. Configure your company details, payment gateways, and email settings from the Settings panel.

## Notes

- First startup takes 2-3 minutes while Laravel seeds the database
- Payment gateway integrations (Stripe, PayPal, etc.) require additional API key configuration
- Client portal is available at the same URL for customers to view and pay invoices
