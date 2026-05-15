# iDempiere

Enterprise-grade open-source ERP and CRM based on the ADempiere/Compiere codebase. Covers accounting, supply chain, manufacturing, and HR with a plugin architecture.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/erp/idempiere/idempiere-ubuntu.sh
chmod +x idempiere-ubuntu.sh
sudo bash idempiere-ubuntu.sh
```

## What It Installs

- **iDempiere** — ERP/CRM application (OSGi/Eclipse RCP)
- **PostgreSQL 13** — database backend

## Credentials

| Field | Value |
| --- | --- |
| URL | http://\<server-ip\>:8121/webui/ |
| Username | GardenAdmin |
| Password | GardenAdmin |

## Ports

| Port | Service |
| --- | --- |
| 8121 | iDempiere Web UI |

## Connect

Open `http://<server-ip>:8121/webui/` and log in with the default credentials above. Change the password immediately after first login from System → User → Change Password.

## Notes

- First startup takes 3-5 minutes while iDempiere initializes the OSGi plugin framework
- Default login uses the Garden World demo company — create a real client via System Admin → Client Setup
- iDempiere is Java/OSGi-based and requires at least 2 GB RAM
