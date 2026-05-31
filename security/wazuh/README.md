# Wazuh — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Wazuh is an open-source security monitoring platform providing SIEM, XDR, intrusion detection, log analysis, and compliance monitoring across your infrastructure.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Wazuh?

Wazuh is an enterprise-grade security platform that collects, analyzes, and correlates security events from agents installed on servers, endpoints, and cloud workloads. It provides real-time threat detection, vulnerability assessment, file integrity monitoring, compliance reporting (PCI DSS, HIPAA, GDPR), and a rich OpenSearch-based dashboard.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/security/wazuh/wazuh-ubuntu.sh
chmod +x wazuh-ubuntu.sh
sudo bash wazuh-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure credentials and TLS certificates
- Sets `vm.max_map_count` required by the OpenSearch indexer
- Starts the Wazuh manager, indexer, and dashboard
- Runs a health check (may take 3–5 minutes)

---

## Access

| | |
|---|---|
| **Dashboard** | `https://SERVER_IP:8443` (HTTPS, accept SSL warning) |
| **Username** | `admin` |
| **Password** | Auto-generated during install (displayed in terminal) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8443` | TCP | Dashboard (HTTPS) |
| `1514` | UDP | Agent log collection |
| `1515` | TCP | Agent enrollment |
| `55000` | TCP | Wazuh API |
| `9200` | TCP | OpenSearch indexer |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/wazuh/` | All service data and configuration |
| `/root/docker/wazuh/manager-data/` | Wazuh manager data |
| `/root/docker/wazuh/indexer-data/` | OpenSearch index data |

---

## Management

```bash
# Follow logs
docker logs -f wazuh-dashboard
docker logs -f wazuh-manager

# Stop
cd /root/docker/wazuh && docker compose down

# Start
cd /root/docker/wazuh && docker compose up -d

# Update to latest image
cd /root/docker/wazuh && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- At least 4 GB RAM (8 GB recommended)
- Ports 8443/tcp, 1514/udp, 1515/tcp, 55000/tcp, 9200/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
