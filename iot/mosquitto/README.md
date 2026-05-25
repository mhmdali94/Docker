# Mosquitto

Lightweight MQTT message broker by Eclipse. The backbone for IoT device communication — smart home sensors, ESP devices, Zigbee gateways, and Home Assistant all use MQTT.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/iot/mosquitto/mosquitto-ubuntu.sh
chmod +x mosquitto-ubuntu.sh
sudo bash mosquitto-ubuntu.sh
```

## What It Installs

- **Eclipse Mosquitto 2** — MQTT broker

## Ports

| Port | Protocol | Service |
| --- | --- | --- |
| 1883 | TCP | MQTT |
| 9001 | TCP | MQTT over WebSocket |

## Access

Connect any MQTT client to `<server-ip>:1883`.

## Authentication

The installer asks whether to enable username/password auth. If enabled, credentials are shown at the end and stored in `./config/passwd`.

To add more users after install:
```bash
docker exec mosquitto mosquitto_passwd /mosquitto/config/passwd newuser
docker restart mosquitto
```

## Testing

```bash
# Subscribe to a topic
mosquitto_sub -h <server-ip> -t "test/#" -u mqtt -P password

# Publish a message
mosquitto_pub -h <server-ip> -t "test/hello" -m "world" -u mqtt -P password
```

## Integration with Home Assistant

In Home Assistant's `configuration.yaml`:
```yaml
mqtt:
  broker: <server-ip>
  port: 1883
  username: mqtt
  password: yourpassword
```

## Notes

- Messages persisted in `./data/`
- Logs in `./log/mosquitto.log`
- Config in `./config/mosquitto.conf` — restart after changes
- WebSocket support on port 9001 for browser-based MQTT clients
