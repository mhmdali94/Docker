# OpenEMR

The most widely deployed open-source electronic health records and medical practice management system. Covers patient scheduling, clinical notes, e-prescribing, billing, and reporting.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/clinic/openemr/openemr-ubuntu.sh
chmod +x openemr-ubuntu.sh
sudo bash openemr-ubuntu.sh
```

## What It Installs

- **OpenEMR** — EHR and practice management
- **MariaDB 10.6** — database backend

## Credentials

| Field | Value |
| --- | --- |
| URL | http://\<server-ip\>:8124 |
| Username | admin |
| Password | Generated at install |

## Ports

| Port | Service |
| --- | --- |
| 8124 | OpenEMR Web UI |

## Connect

Open `http://<server-ip>:8124` and log in with `admin` and the password shown at install. Complete the initial setup wizard to configure your practice details, patient portal, and billing settings.

## Notes

- First startup takes 3-5 minutes while OpenEMR initializes and migrates the database
- Supports Arabic (RTL) and 30+ other languages via Administration → Internationalization
- Optional patient portal can be enabled after initial setup
