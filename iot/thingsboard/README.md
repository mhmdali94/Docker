# ThingsBoard — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [ThingsBoard](https://thingsboard.io) — an IoT platform for device management, data collection and visualization.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/iot/thingsboard/thingsboard-ubuntu.sh
chmod +x thingsboard-ubuntu.sh
sudo bash thingsboard-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| System admin | `sysadmin@thingsboard.org` / `sysadmin` |
| Tenant | `tenant@thingsboard.org` / `tenant` |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8158` | Web UI |
| `1884` | MQTT |
| `5683-5688/udp` | CoAP/LwM2M |

## 💻 Connect

```bash
http://SERVER_IP:8158
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
