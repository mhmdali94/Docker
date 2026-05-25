# Zigbee2MQTT

Bridge Zigbee devices to MQTT without a proprietary hub. 3000+ supported devices — Philips Hue, IKEA, Aqara, Sonoff, and more. Works with Home Assistant.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/iot/zigbee2mqtt/zigbee2mqtt-ubuntu.sh
chmod +x zigbee2mqtt-ubuntu.sh
sudo bash zigbee2mqtt-ubuntu.sh
```

## What It Installs

- **Zigbee2MQTT** — Zigbee to MQTT bridge with web frontend

## Requirements

- A Zigbee USB coordinator (not included):
  - **Sonoff Zigbee 3.0 USB Dongle Plus** (recommended)
  - **ConBee II** or **RaspBee II**
  - **CC2531** (older, limited)
- A running **MQTT broker** (install Mosquitto first)

## Ports

| Port | Service |
| --- | --- |
| 8080 | Zigbee2MQTT web frontend |

## Access

| | URL |
| --- | --- |
| Frontend | `http://<server-ip>:8080` |

## Pairing Devices

1. Open the web frontend
2. Pairing is enabled by default (`permit_join: true`)
3. Put your Zigbee device in pairing mode (usually hold the button)
4. It appears in the frontend within seconds
5. **Disable pairing after setup** — edit `./data/configuration.yaml`:
   ```yaml
   permit_join: false
   ```

## Integration with Home Assistant

Zigbee2MQTT publishes device data to MQTT topics. Home Assistant auto-discovers devices via MQTT integration:

1. Install Mosquitto (this repo)
2. Install Zigbee2MQTT (this script)
3. In Home Assistant: **Settings → Devices & Services → Add Integration → MQTT**

## Configuration

Edit `./data/configuration.yaml` — restart container after changes:
```bash
docker restart zigbee2mqtt
```

## Notes

- 3000+ supported devices at [zigbee2mqtt.io/supported-devices](https://www.zigbee2mqtt.io/supported-devices/)
- Device pairing data stored in `./data/`
- No cloud required — fully local
