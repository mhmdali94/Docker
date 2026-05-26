# Kimai

Open-source time tracking for freelancers and teams. Track time on projects and clients, generate invoices, and export reports — all self-hosted.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/kimai/kimai-ubuntu.sh
chmod +x kimai-ubuntu.sh
sudo bash kimai-ubuntu.sh
```

## What It Installs

- **Kimai 2** — Time tracking application
- **MySQL 8.0** — Database

## Ports

| Port | Service |
| --- | --- |
| 8001 | Kimai web UI |

## Access

| | URL |
| --- | --- |
| Web UI | `http://<server-ip>:8001` |

## Default Credentials

| Field | Value |
| --- | --- |
| Email | Set during install |
| Password | Generated during install (shown at end) |

## Features

- Start/stop timers with one click
- Assign time to projects, activities, and customers
- Invoice generation (PDF) from tracked time
- Team management with role-based access
- Detailed reports by date, project, user, or customer
- Mobile-friendly — use from phone browser

## Notes

- Data stored in `./data/`, plugins in `./plugins/`
- MySQL data in `./mysql/`
- REST API available for integrations
- Export to Excel, CSV, PDF, and more
