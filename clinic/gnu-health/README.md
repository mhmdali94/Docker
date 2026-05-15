# GNU Health

Free and open-source health and hospital information system (HIS). Covers patient management, electronic health records, laboratory, pharmacy, and epidemiology.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/clinic/gnu-health/gnu-health-ubuntu.sh
chmod +x gnu-health-ubuntu.sh
sudo bash gnu-health-ubuntu.sh
```

## What It Installs

- **GNU Health Server** — Tryton-based HIS application
- **PostgreSQL 14** — database backend

## Credentials

| Field | Value |
| --- | --- |
| Server | \<server-ip\>:8000 |
| Username | admin |
| Password | Generated at install |

## Ports

| Port | Service |
| --- | --- |
| 8000 | GNU Health / Tryton server |
| 8123 | Tryton Web Client |

## Connect

Open `http://<server-ip>:8123` in your browser to access the Tryton Web Client. Connect to the server at `<server-ip>:8000`, select the `gnuhealth` database, and log in with `admin` and the password shown at install.

## Notes

- GNU Health is built on the Tryton platform — the web client is the primary interface
- First startup initializes the PostgreSQL database and may take 2-3 minutes
- For full clinical workflows, install the GNU Health HMIS modules from the Tryton Module Manager
