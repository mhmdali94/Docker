# Traccar — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Traccar](https://www.traccar.org) — a GPS tracking platform supporting 2000+ device protocols.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/iot/traccar/traccar-ubuntu.sh
chmod +x traccar-ubuntu.sh
sudo bash traccar-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8217` | Web UI |
| `5155` | OsmAnd/phone protocol |

## 💻 Connect

```bash
http://SERVER_IP:8217
```

## 📝 Notes

- Hardware trackers use protocol-specific ports (5001-5250) — map the ones you need in docker-compose.yml.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
