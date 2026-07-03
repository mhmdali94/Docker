# ESPHome — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [ESPHome](https://esphome.io) — firmware builder and dashboard for ESP32/ESP8266 smart home devices.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/iot/esphome/esphome-ubuntu.sh
chmod +x esphome-ubuntu.sh
sudo bash esphome-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `6052` | Dashboard |

## 💻 Connect

```bash
http://SERVER_IP:6052
```

## 📝 Notes

- mDNS discovery works best with `network_mode: host` — switch the compose file if devices don't appear.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
