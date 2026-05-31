# Home Assistant — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Home Assistant is the leading open-source home automation platform, integrating with over 3,000 devices and services to give you local control of your entire smart home.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Home Assistant?

Home Assistant acts as a central hub for smart home devices — lights, thermostats, cameras, sensors, locks, and more. It runs entirely on your local network with no cloud dependency, supports complex automations, and provides a beautiful dashboard for monitoring and control. Mobile apps are available for iOS and Android.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/iot/homeassistant/homeassistant-ubuntu.sh
chmod +x homeassistant-ubuntu.sh
sudo bash homeassistant-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for your timezone
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:8123` |
| **Username** | Created on first visit |
| **Password** | Created on first visit |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8123` | TCP | Web UI / API |

> Home Assistant uses host networking mode to discover LAN devices via mDNS, Bluetooth, and local protocols.

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/homeassistant/` | All service data and configuration |
| `/root/docker/homeassistant/config/` | YAML configs, automations, integrations |

---

## Management

```bash
# Follow logs
docker logs -f homeassistant

# Stop
cd /root/docker/homeassistant && docker compose down

# Start
cd /root/docker/homeassistant && docker compose up -d

# Update to latest image
cd /root/docker/homeassistant && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8123/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
