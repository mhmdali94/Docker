# Grafana Loki + Promtail — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Grafana Loki](https://grafana.com/oss/loki/) + [Promtail](https://grafana.com/docs/loki/latest/send-data/promtail/) — log aggregation system designed to work with Grafana. Collects system and container logs with minimal overhead.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/monitoring/loki/loki-ubuntu.sh
chmod +x loki-ubuntu.sh
sudo bash loki-ubuntu.sh
```

## 🔑 Credentials

No credentials — integrate via Grafana data source.

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `3100` | Loki API (log ingestion + query) |

## 💻 Connect

```bash
# Loki API health
http://SERVER_IP:3100/ready

# Add as Grafana data source
# Grafana → Configuration → Data Sources → Loki
# URL: http://SERVER_IP:3100
```

## 💡 Grafana Integration

1. Open Grafana → Configuration → Data Sources
2. Add data source → **Loki**
3. URL: `http://loki:3100` (if on same Docker network) or `http://SERVER_IP:3100`
4. Go to Explore → select Loki → query logs with `{job="varlogs"}`

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
