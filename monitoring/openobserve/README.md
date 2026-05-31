# OpenObserve — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

OpenObserve is a cloud-native observability platform for logs, metrics, traces, and dashboards with up to 140x lower storage cost than Elasticsearch.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is OpenObserve?

OpenObserve (O2) is a lightweight, high-performance observability platform built in Rust. It ingests logs, metrics, and traces via standard protocols (OpenTelemetry, Elasticsearch API, InfluxDB API) and provides a built-in dashboard engine for visualization. Its columnar storage format delivers up to 140x compression compared to Elasticsearch, making it ideal for cost-conscious self-hosted environments.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/monitoring/openobserve/openobserve-ubuntu.sh
chmod +x openobserve-ubuntu.sh
sudo bash openobserve-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:5080` |
| **Email** | `root@example.com` |
| **Password** | Auto-generated during install (displayed in terminal) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `5080` | TCP | Web UI & API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/openobserve/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f openobserve

# Stop
cd /root/docker/openobserve && docker compose down

# Start
cd /root/docker/openobserve && docker compose up -d

# Update to latest image
cd /root/docker/openobserve && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 5080/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
