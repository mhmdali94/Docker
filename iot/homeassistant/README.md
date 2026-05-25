# Home Assistant

Open-source home automation platform. Integrates with 3000+ devices and services — smart lights, thermostats, cameras, sensors, voice assistants, and more.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/iot/homeassistant/homeassistant-ubuntu.sh
chmod +x homeassistant-ubuntu.sh
sudo bash homeassistant-ubuntu.sh
```

## What It Installs

- **Home Assistant** — Home automation hub

## Ports

| Port | Service |
| --- | --- |
| 8123 | Home Assistant web UI |

Home Assistant uses `network_mode: host` so it can discover devices on your local network via mDNS, Bluetooth, and Zigbee bridges.

## Access

| | URL |
| --- | --- |
| Dashboard | `http://<server-ip>:8123` |

## Default Credentials

None — the first visit creates your owner account.

## Configuration

All config lives in `./config/`:

| File | Purpose |
| --- | --- |
| `configuration.yaml` | Core settings, integrations |
| `automations.yaml` | Automation rules |
| `scripts.yaml` | Reusable scripts |
| `scenes.yaml` | Device scenes |

## Common Integrations

- **Zigbee2MQTT** — Zigbee devices via USB dongle
- **Mosquitto** — MQTT broker for IoT devices
- **Google Home / Alexa** — Voice assistant control
- **ESPHome** — DIY ESP32/ESP8266 devices
- **Tasmota** — Flashed smart plugs and switches

## Notes

- Runs privileged with host networking for full device discovery
- Config persists in `./config/` across restarts
- Supports energy monitoring, dashboards (Lovelace), and automations
- Mobile apps available for iOS and Android
