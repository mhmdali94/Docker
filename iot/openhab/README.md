# openHAB — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [openHAB](https://www.openhab.org) — the vendor-neutral open home automation platform (Home Assistant alternative).

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/iot/openhab/openhab-ubuntu.sh
chmod +x openhab-ubuntu.sh
sudo bash openhab-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8187` | Web UI |

## 💻 Connect

```bash
http://SERVER_IP:8187
```

## 📝 Notes

- For device auto-discovery (mDNS/UPnP), consider switching to `network_mode: host`.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
