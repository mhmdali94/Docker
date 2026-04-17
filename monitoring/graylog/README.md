# Graylog — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Graylog](https://graylog.org/) — a centralized log management platform built on MongoDB and OpenSearch.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/monitoring/graylog/graylog-ubuntu.sh
chmod +x graylog-ubuntu.sh
sudo bash graylog-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `9000` | Graylog Web UI & REST API |
| `12201/UDP` | GELF UDP input |
| `5140/TCP` | Syslog TCP input |
| `5140/UDP` | Syslog UDP input |

## 💻 Connect

```bash
# Web UI
http://SERVER_IP:9000

# Send a GELF test message
echo '{"version":"1.1","host":"test","short_message":"Hello Graylog","level":1}' | \
  nc -w1 -u SERVER_IP 12201
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
