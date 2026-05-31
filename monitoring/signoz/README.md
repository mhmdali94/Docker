# SigNoz — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

SigNoz is an open-source observability platform for traces, metrics, and logs — OpenTelemetry native with no vendor lock-in. A self-hosted Datadog/New Relic alternative.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is SigNoz?

SigNoz provides a unified platform for application observability built entirely on OpenTelemetry. It collects distributed traces, metrics, and logs through OTLP receivers, stores them in ClickHouse for high-performance querying, and presents everything in a clean web dashboard. It replaces the need for separate tools like Jaeger (traces), Prometheus (metrics), and Loki (logs) with a single integrated solution.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/monitoring/signoz/signoz-ubuntu.sh
chmod +x signoz-ubuntu.sh
sudo bash signoz-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure credentials
- Configures ClickHouse, Query Service, and Frontend
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:3301` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3301` | TCP | Frontend (Web UI) |
| `8080` | TCP | Query Service API |
| `4317` | TCP | OTLP gRPC receiver |
| `4318` | TCP | OTLP HTTP receiver |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/signoz/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f signoz-frontend

# Stop
cd /root/docker/signoz && docker compose down

# Start
cd /root/docker/signoz && docker compose up -d

# Update to latest image
cd /root/docker/signoz && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 3301, 8080, 4317, 4318/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
