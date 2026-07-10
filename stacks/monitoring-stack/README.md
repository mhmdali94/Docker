# Monitoring Stack — One-Command Stack

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

**Prometheus + Grafana + node-exporter + cAdvisor**, with the datasource and a Host Overview dashboard **already provisioned** — log into Grafana and the graphs are live.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/stacks/monitoring-stack/monitoring-stack-ubuntu.sh
chmod +x monitoring-stack-ubuntu.sh
sudo bash monitoring-stack-ubuntu.sh
```

## 📦 What's inside

- **Prometheus** — metrics database (pre-configured scrapes)
- **node-exporter** — host CPU/RAM/disk/network
- **cAdvisor** — per-container metrics
- **Grafana** — dashboards (datasource + host dashboard auto-provisioned)

## 🌐 Ports

| Port | Service |
|------|---------|
| `3000` | Grafana |
| `9090` | Prometheus |

## 🔗 Wiring

Zero manual steps: Prometheus already scrapes node-exporter and cAdvisor; Grafana already has the Prometheus datasource and a 'Host Overview' dashboard. Import IDs `1860`/`14282` for more depth.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
