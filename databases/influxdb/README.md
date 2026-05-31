# InfluxDB — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Purpose-built time-series database for metrics, events, and real-time analytics.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is InfluxDB?

InfluxDB is an open-source time-series database optimized for storing and querying metrics, events, and sensor data at high ingestion rates. It includes a web-based UI for exploring data, a Flux query language, built-in downsampling and retention policies, and integrates natively with Grafana, Telegraf, and the entire InfluxData TICK stack.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/databases/influxdb/influxdb-ubuntu.sh
chmod +x influxdb-ubuntu.sh
sudo bash influxdb-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:8086` |
| **Username** | `influxadmin` |
| **Password** | Auto-generated (shown at install) |
| **Organization** | `myorg` |
| **Bucket** | `mybucket` |
| **Admin Token** | Auto-generated (shown at install) |

> Replace `SERVER_IP` with your server's IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8086` | TCP | Web UI / HTTP API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/influxdb/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f influxdb

# Stop the service
cd /root/docker/influxdb && docker compose down

# Start the service
cd /root/docker/influxdb && docker compose up -d

# Update to latest image
cd /root/docker/influxdb && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 8086/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
