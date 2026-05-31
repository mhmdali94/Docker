# Mosquitto — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Eclipse Mosquitto is a lightweight, open-source MQTT message broker that serves as the backbone for IoT device communication, smart home sensors, and Home Assistant integrations.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Mosquitto?

Mosquitto implements the MQTT protocol, enabling low-overhead publish/subscribe messaging between IoT devices. It is the standard broker used with Home Assistant, ESP devices, Zigbee2MQTT, Tasmota, and thousands of other IoT systems. The installer offers optional username/password authentication.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/iot/mosquitto/mosquitto-ubuntu.sh
chmod +x mosquitto-ubuntu.sh
sudo bash mosquitto-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for authentication mode (anonymous or username/password)
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **MQTT (TCP)** | `SERVER_IP:1883` |
| **MQTT (WebSocket)** | `SERVER_IP:9001` |
| **Username** | Auto-generated during install (if auth enabled) |
| **Password** | Auto-generated during install (if auth enabled) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `1883` | TCP | MQTT broker |
| `9001` | TCP | MQTT over WebSocket |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/mosquitto/` | All service data and configuration |
| `/root/docker/mosquitto/config/` | Broker configuration and password file |
| `/root/docker/mosquitto/data/` | Persistent message storage |
| `/root/docker/mosquitto/log/` | Broker logs |

---

## Management

```bash
# Follow logs
docker logs -f mosquitto

# Stop
cd /root/docker/mosquitto && docker compose down

# Start
cd /root/docker/mosquitto && docker compose up -d

# Update to latest image
cd /root/docker/mosquitto && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 1883/tcp and 9001/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
