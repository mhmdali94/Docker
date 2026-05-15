# IceHRM

Open-source HR management system with employee profiles, leave management, attendance tracking, payroll, and document management.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/hr/icehrm/icehrm-ubuntu.sh
chmod +x icehrm-ubuntu.sh
sudo bash icehrm-ubuntu.sh
```

## What It Installs

- **IceHRM** — HR management application
- **MySQL 8** — database backend

## Credentials

| Field | Value |
| --- | --- |
| URL | http://\<server-ip\>:8126 |
| Username | admin |
| Password | Generated at install |

## Ports

| Port | Service |
| --- | --- |
| 8126 | IceHRM Web UI |

## Connect

Open `http://<server-ip>:8126` and log in with `admin` and the password shown at install. Start by adding your company structure, departments, and employee records.

## Notes

- IceHRM is lightweight and suitable for SME deployments
- Attendance can be tracked via IP-based or biometric device integration
- Payroll module supports custom salary components and tax rules
