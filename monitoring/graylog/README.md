# Graylog — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Graylog is a centralized log management platform that collects, indexes, and analyzes logs from your entire infrastructure in real time with powerful search and alerting capabilities.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Graylog?

Graylog ingests log data from servers, applications, firewalls, and network devices via Syslog, GELF, Beats, and other inputs. It stores logs in OpenSearch for fast full-text search, provides stream-based log routing, and supports complex alert conditions with email, Slack, or PagerDuty notifications.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/monitoring/graylog/graylog-ubuntu.sh
chmod +x graylog-ubuntu.sh
sudo bash graylog-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure credentials
- Tunes `vm.max_map_count` for OpenSearch
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:9000` |
| **Username** | `admin` |
| **Password** | Auto-generated during install (displayed in terminal) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `9000` | TCP | Web UI / REST API |
| `12201` | UDP | GELF UDP log ingestion |
| `5140` | TCP | Syslog TCP ingestion |
| `5140` | UDP | Syslog UDP ingestion |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/graylog/` | All service data and configuration |
| `/root/docker/graylog/graylog-data/` | Graylog journal and configuration |
| `/root/docker/graylog/opensearch-data/` | OpenSearch index data |
| `/root/docker/graylog/mongo-data/` | MongoDB metadata |

---

## Management

```bash
# Follow logs
docker logs -f graylog

# Stop
cd /root/docker/graylog && docker compose down

# Start
cd /root/docker/graylog && docker compose up -d

# Update to latest image
cd /root/docker/graylog && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- At least 4 GB RAM (OpenSearch requirement)
- Ports 9000, 12201/udp, 5140/tcp, 5140/udp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
