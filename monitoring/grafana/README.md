# Grafana — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Grafana is the leading open-source platform for monitoring and observability dashboards, enabling you to query, visualize, and alert on metrics, logs, and traces from any data source.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Grafana?

Grafana connects to data sources like Prometheus, Loki, InfluxDB, Elasticsearch, and dozens more to build interactive, real-time dashboards. It provides powerful alerting, annotation support, and a plugin ecosystem with hundreds of community dashboards ready to import. Pairs naturally with Prometheus for infrastructure monitoring and Loki for log analysis.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/monitoring/grafana/grafana-ubuntu.sh
chmod +x grafana-ubuntu.sh
sudo bash grafana-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:3000` |
| **Username** | `admin` |
| **Password** | Auto-generated during install (displayed in terminal) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3000` | TCP | Web UI / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/grafana/` | All service data and configuration |
| `/root/docker/grafana/data/` | Dashboards, users, and plugin data |
| `/root/docker/grafana/provisioning/` | Provisioned data sources and dashboards |

---

## Management

```bash
# Follow logs
docker logs -f grafana

# Stop
cd /root/docker/grafana && docker compose down

# Start
cd /root/docker/grafana && docker compose up -d

# Update to latest image
cd /root/docker/grafana && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 3000/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
