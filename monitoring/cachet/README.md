# Cachet

Beautiful open-source status page system. Show your users the real-time status of your services, post incident updates, and build trust through transparency.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/monitoring/cachet/cachet-ubuntu.sh
chmod +x cachet-ubuntu.sh
sudo bash cachet-ubuntu.sh
```

## What It Installs

- **Cachet** — Status page system
- **PostgreSQL 15** — Database

## Ports

| Port | Service |
| --- | --- |
| 8099 | Cachet status page + admin |

## Access

| | URL |
| --- | --- |
| Status Page | `http://<server-ip>:8099` |
| Admin | `http://<server-ip>:8099/dashboard` |

## Default Credentials

None — a setup wizard runs on first visit.

## Features

- Public status page showing component health
- Incident management with real-time updates
- Scheduled maintenance announcements
- Subscriber email notifications
- Metrics graphs (response time, uptime)
- REST API for automated incident creation
- Multiple component groups

## Notes

- PostgreSQL data stored in `./postgres/`
- Integrate with monitoring tools (Uptime Kuma, Gatus) to auto-update component status via API
