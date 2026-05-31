# MongoDB — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Document-oriented NoSQL database for flexible, schema-free data storage at scale.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is MongoDB?

MongoDB is the world's most popular document database. It stores data as flexible JSON-like documents, making it easy to model complex, hierarchical data without a rigid schema. Supports horizontal scaling, rich query language, aggregation pipelines, and change streams. Widely used with Node.js, Python, and modern web stacks.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/databases/mongodb/mongodb-ubuntu.sh
chmod +x mongodb-ubuntu.sh
sudo bash mongodb-ubuntu.sh
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
| **Database Port** | `SERVER_IP:27017` |
| **Username** | `mongoadmin` |
| **Password** | Auto-generated (shown at install) |
| **Auth DB** | `admin` |

> Replace `SERVER_IP` with your server's IP address. Connection string: `mongodb://mongoadmin:PASSWORD@SERVER_IP:27017/`

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `27017` | TCP | MongoDB protocol |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/mongodb/` | All service data and configuration |

---

## Management

```bash
# Connect via Docker
docker exec -it mongodb mongosh -u mongoadmin -p --authenticationDatabase admin

# Follow logs
docker logs -f mongodb

# Stop the service
cd /root/docker/mongodb && docker compose down

# Start the service
cd /root/docker/mongodb && docker compose up -d

# Update to latest image
cd /root/docker/mongodb && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 27017/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
