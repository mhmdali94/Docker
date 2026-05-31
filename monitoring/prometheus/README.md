# Prometheus — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Prometheus is an open-source systems monitoring and alerting toolkit with a powerful query language (PromQL) and time-series data collection.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Prometheus?

Prometheus collects metrics from instrumented targets via HTTP pull, stores them in a time-series database, and supports PromQL for flexible querying and alerting. It is the de facto standard for cloud-native infrastructure monitoring, pairing naturally with Grafana for dashboarding, Alertmanager for notifications, and exporters (like Node Exporter) for system metrics.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/monitoring/prometheus/prometheus-ubuntu.sh
chmod +x prometheus-ubuntu.sh
sudo bash prometheus-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Creates scrape config for self-monitoring and Node Exporter
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:9090` |
| **Username** | None (open by default) |
| **Password** | None (open by default) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `9090` | TCP | Web UI & API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/prometheus/` | All service data and configuration |
| `/root/docker/prometheus/prometheus.yml` | Scrape configuration |

---

## Management

```bash
# Follow logs
docker logs -f prometheus

# Stop
cd /root/docker/prometheus && docker compose down

# Start
cd /root/docker/prometheus && docker compose up -d

# Update to latest image
cd /root/docker/prometheus && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 9090/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
