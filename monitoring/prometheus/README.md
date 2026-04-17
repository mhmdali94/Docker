# Prometheus — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Prometheus](https://prometheus.io/) — an open-source systems monitoring and alerting toolkit with a powerful query language (PromQL).

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/monitoring/prometheus/prometheus-ubuntu.sh
chmod +x prometheus-ubuntu.sh
sudo bash prometheus-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Auth | None (open by default) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `9090` | Prometheus Web UI & API |

## 💻 Connect

```bash
# Web UI
http://SERVER_IP:9090

# Query example (PromQL)
http://SERVER_IP:9090/graph?g0.expr=up

# Config file location
/root/docker/prometheus/prometheus.yml
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
