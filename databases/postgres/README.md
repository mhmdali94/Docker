# PostgreSQL — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

The world's most advanced open-source relational database system — powerful, reliable, and feature-rich.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is PostgreSQL?

PostgreSQL is a powerful open-source object-relational database with over 35 years of active development. It supports advanced SQL features including JSON, full-text search, JSONB, window functions, CTEs, and extensions like PostGIS. Used as the backend database for many open-source applications.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/databases/postgres/postgres-ubuntu.sh
chmod +x postgres-ubuntu.sh
sudo bash postgres-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure credentials
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Database Port** | `SERVER_IP:5432` |
| **User** | `pgadmin` |
| **Database** | `pgdb` |
| **Password** | Auto-generated (shown at install) |

> Replace `SERVER_IP` with your server's IP address. Connect: `psql -h SERVER_IP -U pgadmin -d pgdb`

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `5432` | TCP | PostgreSQL protocol |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/postgres/` | All service data and configuration |

---

## Management

```bash
# Connect via Docker
docker exec -it postgres psql -U pgadmin -d pgdb

# Follow logs
docker logs -f postgres

# Stop the service
cd /root/docker/postgres && docker compose down

# Start the service
cd /root/docker/postgres && docker compose up -d

# Update to latest image
cd /root/docker/postgres && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 5432/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
