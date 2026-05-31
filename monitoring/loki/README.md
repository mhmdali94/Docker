# Grafana Loki + Promtail — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Grafana Loki is a log aggregation system inspired by Prometheus, designed to collect and query logs with minimal overhead. Paired with Promtail for log shipping and Grafana for visualization.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Grafana Loki?

Loki is a horizontally scalable, highly available log aggregation system from Grafana Labs. Unlike Elasticsearch, Loki does not index the contents of logs — it only indexes metadata (labels), making it far more efficient in storage and resource usage. Promtail is the agent that ships logs to Loki, collecting system and container logs automatically. Combined with Grafana, it provides a complete observability stack for infrastructure monitoring.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/monitoring/loki/loki-ubuntu.sh
chmod +x loki-ubuntu.sh
sudo bash loki-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Creates Loki and Promtail configuration files
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Loki API** | `http://SERVER_IP:3100` |
| **Username** | None (no authentication) |
| **Password** | None (no authentication) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3100` | TCP | Loki API (log ingestion + query) |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/loki/` | All service data and configuration |
| `/root/docker/loki/loki-config.yaml` | Loki configuration |
| `/root/docker/loki/promtail-config.yaml` | Promtail configuration |

---

## Management

```bash
# Follow logs
docker logs -f loki

# Stop
cd /root/docker/loki && docker compose down

# Start
cd /root/docker/loki && docker compose up -d

# Update to latest image
cd /root/docker/loki && docker compose pull && docker compose up -d
```

---

## Grafana Integration

1. Open Grafana → Configuration → Data Sources
2. Add data source → **Loki**
3. URL: `http://loki:3100` (if on same Docker network) or `http://SERVER_IP:3100`
4. Go to Explore → select Loki → query logs with `{job="varlogs"}`

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 3100/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
