# OpenObserve — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [OpenObserve](https://openobserve.ai/) — cloud-native observability platform for logs, metrics, traces, and dashboards. Up to 140x lower storage cost than Elasticsearch/OpenSearch.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/monitoring/openobserve/openobserve-ubuntu.sh
chmod +x openobserve-ubuntu.sh
sudo bash openobserve-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Email | `root@example.com` |
| Password | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `5080` | OpenObserve Web UI & API |

## 💻 Connect

```bash
# Web UI
http://SERVER_IP:5080

# Ingest logs (API)
curl -u root@example.com:YOUR_PASSWORD \
  -X POST http://SERVER_IP:5080/api/default/logs/_json \
  -H 'Content-Type: application/json' \
  -d '[{"level":"info","message":"test log"}]'
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
