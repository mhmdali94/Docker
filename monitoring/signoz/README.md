# SigNoz — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [SigNoz](https://signoz.io/) — open-source observability platform. Traces, metrics, and logs in one place. OpenTelemetry native, no vendor lock-in. A self-hosted Datadog/New Relic alternative.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/monitoring/signoz/signoz-ubuntu.sh
chmod +x signoz-ubuntu.sh
sudo bash signoz-ubuntu.sh
```

## 🔑 Credentials

No default credentials — create your admin account on first visit.

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `3301` | SigNoz Frontend (Web UI) |
| `8080` | Query Service API |
| `4317` | OTLP gRPC receiver |
| `4318` | OTLP HTTP receiver |

## 💻 Connect

```bash
# Web UI
http://SERVER_IP:3301

# Send traces from your app (OpenTelemetry)
OTEL_EXPORTER_OTLP_ENDPOINT=http://SERVER_IP:4318
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
