# EMQX — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [EMQX](https://www.emqx.io) — a scalable, enterprise-grade MQTT broker with a management dashboard.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/iot/emqx/emqx-ubuntu.sh
chmod +x emqx-ubuntu.sh
sudo bash emqx-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | `public` (forced change on first login) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `1885` | MQTT |
| `8883` | MQTT over TLS |
| `18083` | Dashboard |

## 💻 Connect

```bash
mqtt://SERVER_IP:1885
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
