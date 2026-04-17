# Grafana — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Grafana](https://grafana.com/) — the open-source platform for monitoring and observability dashboards.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/monitoring/grafana/grafana-ubuntu.sh
chmod +x grafana-ubuntu.sh
sudo bash grafana-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `3000` | Grafana Web UI |

## 💻 Connect

```bash
# Web UI
http://SERVER_IP:3000

# Add a data source (e.g., Prometheus)
# Settings → Data Sources → Add data source → Prometheus
# URL: http://prometheus:9090
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
