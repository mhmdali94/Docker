# Z-Wave JS UI — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Z-Wave JS UI](https://zwave-js.github.io/zwave-js-ui/) — full-featured Z-Wave control panel and MQTT gateway (pairs with Home Assistant).

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/iot/zwave-js-ui/zwave-js-ui-ubuntu.sh
chmod +x zwave-js-ui-ubuntu.sh
sudo bash zwave-js-ui-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8230` | Web UI |
| `3005` | Z-Wave JS websocket |

## 💻 Connect

```bash
http://SERVER_IP:8230
```

## 📝 Notes

- Add your Z-Wave USB controller under `devices:` in docker-compose.yml and restart.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
