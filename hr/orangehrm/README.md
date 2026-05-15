# OrangeHRM

Open-source human resource management system covering employee records, leave management, time tracking, performance reviews, recruitment, and payroll.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/hr/orangehrm/orangehrm-ubuntu.sh
chmod +x orangehrm-ubuntu.sh
sudo bash orangehrm-ubuntu.sh
```

## What It Installs

- **OrangeHRM** — HR management application
- **MariaDB 10.6** — database backend

## Credentials

| Field | Value |
| --- | --- |
| URL | http://\<server-ip\>:8125 |
| Username | admin |
| Password | Generated at install |

## Ports

| Port | Service |
| --- | --- |
| 8125 | OrangeHRM Web UI |

## Connect

Open `http://<server-ip>:8125` and log in with `admin` and the password shown at install. Complete the setup wizard to configure your organization structure, leave types, and employee records.

## Notes

- First startup takes 2-3 minutes while OrangeHRM initializes the database
- The Community Edition covers core HR features; the Enterprise edition adds payroll and advanced analytics
- Employee self-service portal is available at the same URL
