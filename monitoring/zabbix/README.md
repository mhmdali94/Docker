# Zabbix — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Zabbix](https://www.zabbix.com) — enterprise-grade network and infrastructure monitoring.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/monitoring/zabbix/zabbix-ubuntu.sh
chmod +x zabbix-ubuntu.sh
sudo bash zabbix-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `Admin` |
| Password | `zabbix` (change immediately) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8132` | Web UI |
| `10051` | Zabbix server (agents) |

## 💻 Connect

```bash
http://SERVER_IP:8132
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
