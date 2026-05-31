# MariaDB — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Community-developed relational database and drop-in replacement for MySQL.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is MariaDB?

MariaDB is an open-source relational database management system forked from MySQL by its original developers. It offers full MySQL compatibility, improved performance, additional storage engines, and enterprise-grade features. Widely used as the database backend for WordPress, Drupal, Magento, and many other applications.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/databases/mariadb/mariadb-ubuntu.sh
chmod +x mariadb-ubuntu.sh
sudo bash mariadb-ubuntu.sh
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
| **Database Port** | `SERVER_IP:3306` |
| **User** | `dbadmin` |
| **Database** | `appdb` |
| **Password** | Auto-generated (shown at install) |
| **Root Password** | Auto-generated (shown at install) |

> Replace `SERVER_IP` with your server's IP address. Connect: `mysql -h SERVER_IP -P 3306 -u dbadmin -p appdb`

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3306` | TCP | MySQL/MariaDB protocol |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/mariadb/` | All service data and configuration |

---

## Management

```bash
# Connect via Docker
docker exec -it mariadb mysql -u dbadmin -p appdb

# Follow logs
docker logs -f mariadb

# Stop the service
cd /root/docker/mariadb && docker compose down

# Start the service
cd /root/docker/mariadb && docker compose up -d

# Update to latest image
cd /root/docker/mariadb && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 3306/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
