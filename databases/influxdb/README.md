# InfluxDB — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [InfluxDB](https://www.influxdata.com/) — a purpose-built time-series database for metrics, events, and real-time analytics.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/databases/influxdb/influxdb-ubuntu.sh
chmod +x influxdb-ubuntu.sh
sudo bash influxdb-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | Auto-generated (shown at install) |
| Organization | `myorg` |
| Bucket | `mybucket` |
| Admin Token | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8086` | InfluxDB HTTP API + Web UI |

## 💻 Connect

```bash
# Web UI
http://SERVER_IP:8086

# Write data via API
curl -X POST "http://SERVER_IP:8086/api/v2/write?org=myorg&bucket=mybucket" \
  -H "Authorization: Token YOUR_TOKEN" \
  --data-raw "cpu,host=server01 usage=42.3"
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
