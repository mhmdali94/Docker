# OpenMRS

Open-source electronic medical records system used by hospitals and clinics in over 40 countries. Modular platform with patient registration, visit tracking, orders, and clinical reporting.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/clinic/openmrs/openmrs-ubuntu.sh
chmod +x openmrs-ubuntu.sh
sudo bash openmrs-ubuntu.sh
```

## What It Installs

- **OpenMRS Reference Application** — EMR platform
- **MySQL 8** — database backend

## Credentials

| Field | Value |
| --- | --- |
| URL | http://\<server-ip\>:8122/openmrs |
| Username | admin |
| Password | Admin123 |

## Ports

| Port | Service |
| --- | --- |
| 8122 | OpenMRS Web UI |

## Connect

Open `http://<server-ip>:8122/openmrs` and log in with `admin` / `Admin123`. Change the password immediately after first login. Navigate to Administration to configure modules and data elements.

## Notes

- First startup takes 5-10 minutes while OpenMRS initializes the database schema
- The reference application includes a full patient-facing registration and clinical workflow
- Additional modules (forms, reports) can be uploaded via the Module Administration page
