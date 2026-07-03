# UniFi Network Application — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [UniFi Network Application](https://ui.com) — the UniFi Network controller for managing Ubiquiti access points, switches and gateways.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/networking/unifi/unifi-ubuntu.sh
chmod +x unifi-ubuntu.sh
sudo bash unifi-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8443` | Web UI (HTTPS) |
| `8080` | Device inform |
| `3478/udp` | STUN |
| `10001/udp` | Device discovery |

## 💻 Connect

```bash
https://SERVER_IP:8443
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
