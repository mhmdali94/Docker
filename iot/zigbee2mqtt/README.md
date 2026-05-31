# Zigbee2MQTT — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Zigbee2MQTT bridges Zigbee devices to an MQTT broker without any proprietary hub, supporting over 3,000 devices from Philips Hue, IKEA, Aqara, Sonoff, and more.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Zigbee2MQTT?

Zigbee2MQTT allows you to use Zigbee devices without manufacturer clouds or proprietary apps. A USB Zigbee coordinator on your server talks to all your Zigbee devices, and Zigbee2MQTT publishes their state to an MQTT broker — integrating seamlessly with Home Assistant and other automation platforms.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/iot/zigbee2mqtt/zigbee2mqtt-ubuntu.sh
chmod +x zigbee2mqtt-ubuntu.sh
sudo bash zigbee2mqtt-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for Zigbee adapter path and MQTT broker details
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:8080` |
| **Username** | None (configure in the frontend settings) |
| **Password** | None (configure in the frontend settings) |

> Replace `SERVER_IP` with your server's actual IP address. A Zigbee USB coordinator and a running MQTT broker (e.g., Mosquitto) are required before install.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8080` | TCP | Zigbee2MQTT Web Frontend |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/zigbee2mqtt/` | All service data and configuration |
| `/root/docker/zigbee2mqtt/data/` | Device database and configuration YAML |

---

## Management

```bash
# Follow logs
docker logs -f zigbee2mqtt

# Stop
cd /root/docker/zigbee2mqtt && docker compose down

# Start
cd /root/docker/zigbee2mqtt && docker compose up -d

# Update to latest image
cd /root/docker/zigbee2mqtt && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- A supported Zigbee USB coordinator (e.g., Sonoff Zigbee 3.0 Dongle Plus)
- A running MQTT broker (e.g., Mosquitto)
- Port 8080/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
