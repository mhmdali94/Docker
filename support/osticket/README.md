# osTicket

Lightweight open-source customer support ticketing system. Accept support requests via web form or email, assign to agents, and track resolution — simple and battle-tested.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/support/osticket/osticket-ubuntu.sh
chmod +x osticket-ubuntu.sh
sudo bash osticket-ubuntu.sh
```

## What It Installs

- **osTicket** — Support ticketing system
- **MySQL 8.0** — Database

## Ports

| Port | Service |
| --- | --- |
| 8088 | osTicket (customer portal + admin) |

## Access

| | URL |
| --- | --- |
| Customer Portal | `http://<server-ip>:8088` |
| Staff Control Panel | `http://<server-ip>:8088/scp` |

## Default Credentials

| Field | Value |
| --- | --- |
| Email | `admin@osticket.local` |
| Password | Generated during install (shown at end) |

## Features

- Ticket submission via web form or email
- Auto-assignment to departments and agents
- Custom fields, forms, and ticket filters
- SLA policies and escalation rules
- Canned responses for common issues
- Multi-department and multi-team support
- Customer email notifications

## Notes

- Data and attachments stored in `./data/`
- MySQL data in `./mysql/`
- Configure SMTP in Admin → Emails for incoming/outgoing email
